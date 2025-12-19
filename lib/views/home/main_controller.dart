import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:news_app/services/utils/app_urls.dart';
import 'package:news_app/view_models/index_view_model.dart';
import 'package:news_app/view_models/news_view_model.dart';
import 'package:news_app/views/home/breaking_news_screen.dart';
import 'package:news_app/views/home/settings_screen.dart';
import 'package:news_app/views/home/trending_news_screen.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<NewsViewModel>();

      // Key 1 fetching
      vm.getNews(AppUrls.featured, "featured");
      vm.getNews(AppUrls.trending, "trending");
      vm.getNews(AppUrls.breaking, "breaking");
      vm.getNews(AppUrls.business, "business");
      vm.getNews(AppUrls.sports, "sports");
      vm.getNews(AppUrls.gaming, "gaming");
      //Key 2 fetching
      vm.getNews(AppUrls.recent, "recent");
      vm.getNews(AppUrls.nation, "nation");
      vm.getNews(AppUrls.world, "world");
      vm.getNews(AppUrls.technology, "technology");
      vm.getNews(AppUrls.health, "health");
      vm.getNews(AppUrls.science, "science");
      vm.getNews(AppUrls.entertainment, "entertainment");
    });
  }

  // Removed local state _selectedIndex

  final List<Widget> _pages = [
    const HomeScreen(),
    const TrendingScreen(),
    const BreakingScreen(),
    const SettingsScreen(),
  ];

  Future<void> _handleBackPress() async {
    final indexM = context.read<IndexViewModel>();
    // Check provider state instead of local state
    if (indexM.currentTabIndex != 0) {
      indexM.setTabIndex(0); // Go back to Home tab
      return;
    } else {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Exit App",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Are you sure you want to close the application?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Exit",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (shouldExit == true) {
        SystemNavigator.pop(); // Exit the app
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch the ViewModel to rebuild when tab changes
    final navIndex = context.watch<IndexViewModel>().currentTabIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        body: IndexedStack(index: navIndex, children: _pages),
        bottomNavigationBar: Container(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 15.0,
              bottom: 30,
              right: 15,
              top: 10,
            ),
            child: GNav(
              backgroundColor: isDark
                  ? Colors.grey.shade900
                  : Colors.grey.shade100,
              color: Colors.grey.shade500,
              activeColor: isDark ? Colors.white : Colors.indigo,
              tabBackgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.indigo.withAlpha(50),
              gap: 8,
              padding: const EdgeInsets.all(16),
              selectedIndex: navIndex, // Use value from Provider
              onTabChange: (index) {
                // Update state via Provider
                context.read<IndexViewModel>().setTabIndex(index);
              },

              tabs: const [
                GButton(icon: Icons.home_rounded, text: 'Home'),
                GButton(icon: Icons.trending_up_rounded, text: 'Trending'),
                GButton(icon: Icons.flash_on_rounded, text: 'Breaking'),
                GButton(icon: Icons.settings_rounded, text: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
