import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../services/utils/app_urls.dart';
import '../../utils/size_config.dart';
import '../../view_models/index_view_model.dart';
import '../../view_models/news_view_model.dart';
import '../home/trending_news_screen.dart';
import 'breaking_news_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainController extends StatefulWidget {
  const MainController({super.key});

  @override
  State<MainController> createState() => _MainControllerState();
}

class _MainControllerState extends State<MainController> {
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

  final List<Widget> _pages = const [
    HomeScreen(),
    TrendingScreen(),
    BreakingScreen(),
    SettingsScreen(),
  ];

  Future<void> _handleBackPress() async {
    final indexVM = context.read<IndexViewModel>();

    if (indexVM.currentTabIndex != 0) {
      indexVM.setTabIndex(0);
      return;
    }

    final shouldExit = await _showExitDialog(context);
    if (shouldExit == true) {
      indexVM.reset();
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        body: Consumer<IndexViewModel>(
          builder: (context, indexVM, child) {
            return IndexedStack(
              index: indexVM.currentTabIndex,
              children: _pages,
            );
          },
        ),
        bottomNavigationBar: Container(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          child: SafeArea(
            bottom: true,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 10.h,
                bottom: 1.h,
              ),
              child: Consumer<IndexViewModel>(
                builder: (context, indexVM, child) {
                  return GNav(
                    backgroundColor: isDark
                        ? Colors.grey.shade900
                        : Colors.grey.shade50,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    activeColor: isDark ? Colors.white : Colors.indigo,
                    tabBackgroundColor: isDark
                        ? Colors.white.withAlpha(25)
                        : Colors.indigo.withAlpha(25),
                    gap: 8.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    selectedIndex: indexVM.currentTabIndex,
                    onTabChange: (index) {
                      indexVM.setTabIndex(index);
                    },
                    tabs: [
                      GButton(
                        icon: Icons.home_rounded,
                        iconSize: 24.w,
                        text: 'Home',
                        textStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.indigo,
                        ),
                      ),
                      GButton(
                        icon: Icons.trending_up_rounded,
                        iconSize: 24.w,
                        text: 'Trending',
                        textStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.indigo,
                        ),
                      ),
                      GButton(
                        icon: Icons.flash_on_rounded,
                        iconSize: 24.w,
                        text: 'Breaking',
                        textStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.indigo,
                        ),
                      ),
                      GButton(
                        icon: Icons.settings_rounded,
                        iconSize: 24.w,
                        text: 'Settings',
                        textStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.indigo,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 32.w,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Exit App",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Are you sure you want to close the application?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                        ),
                        child: Text(
                          "Exit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
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
