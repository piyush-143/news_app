import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../services/utils/app_urls.dart';
import '../../view_models/index_view_model.dart';
import '../../view_models/news_view_model.dart';
import '../home/trending_news_screen.dart';
import 'breaking_news_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// The "Shell" of the application.
/// Manages Bottom Navigation, Android Back Button logic, and Initial Data Fetching.
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

      vm.getNews(AppUrls.featured, "featured");
      vm.getNews(AppUrls.trending, "trending");
      vm.getNews(AppUrls.breaking, "breaking");
      vm.getNews(AppUrls.business, "business");
      vm.getNews(AppUrls.sports, "sports");
      vm.getNews(AppUrls.gaming, "gaming");
      vm.getNews(AppUrls.recent, "recent");
      vm.getNews(AppUrls.nation, "nation");
      vm.getNews(AppUrls.world, "world");
      vm.getNews(AppUrls.technology, "technology");
      vm.getNews(AppUrls.health, "health");
      vm.getNews(AppUrls.science, "science");
      vm.getNews(AppUrls.entertainment, "entertainment");
    });
  }

  // Define screens as const where possible to prevent unnecessary rebuilding
  final List<Widget> _pages = const [
    HomeScreen(),
    TrendingScreen(),
    BreakingScreen(),
    SettingsScreen(),
  ];

  /// Handles Android physical back button behavior.
  /// 1. If not on Home Tab -> Go to Home Tab.
  /// 2. If on Home Tab -> Show Exit Dialog.
  Future<void> _handleBackPress() async {
    final indexVM = context.read<IndexViewModel>();

    if (indexVM.currentTabIndex != 0) {
      indexVM.setTabIndex(0); // Navigate to Home
      return;
    }

    // Confirm before closing the app
    final shouldExit = await _showExitDialog(context);
    if (shouldExit == true) {
      indexVM.reset(); // Resets all the index to 0
      SystemNavigator.pop(); // Close App
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // PopScope intercepts the system back button
    return PopScope(
      canPop: false, // Disable default pop to handle it manually
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        // IndexedStack preserves the state (scroll position) of each tab
        // so it doesn't reset when switching tabs.
        body: Consumer<IndexViewModel>(
          builder: (context, indexVM, child) {
            return IndexedStack(
              index: indexVM.currentTabIndex,
              children: _pages,
            );
          },
        ),
        bottomNavigationBar: Container(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 15.0,
              bottom: 30, // Extra padding for modern gesture bars
              right: 15,
              top: 10,
            ),
            child: Consumer<IndexViewModel>(
              builder: (context, indexVM, child) {
                return GNav(
                  backgroundColor: isDark
                      ? Colors.grey.shade900
                      : Colors.grey.shade100,
                  color: Colors.grey.shade500,
                  activeColor: isDark ? Colors.white : Colors.indigo,
                  tabBackgroundColor: isDark
                      ? Colors.grey.shade800
                      : Colors.indigo.withOpacity(0.1),
                  gap: 8,
                  padding: const EdgeInsets.all(16),
                  selectedIndex: indexVM.currentTabIndex,
                  onTabChange: (index) {
                    indexVM.setTabIndex(index);
                  },
                  tabs: const [
                    GButton(icon: Icons.home_rounded, text: 'Home'),
                    GButton(icon: Icons.trending_up_rounded, text: 'Trending'),
                    GButton(icon: Icons.flash_on_rounded, text: 'Breaking'),
                    GButton(icon: Icons.settings_rounded, text: 'Settings'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Displays a styled confirmation dialog before exiting.
  Future<bool?> _showExitDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      builder: (context) {
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
                // Warning Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  "Exit App",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // Message
                Text(
                  "Are you sure you want to close the application?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
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
  }
}
