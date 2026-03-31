import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../models/news_response_model.dart';
import '../../services/utils/app_urls.dart';
import '../../utils/size_config.dart';
import '../../view_models/index_view_model.dart';
import '../../view_models/news_view_model.dart';
import '../../views/home/see_all_screen.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/featured_news_card.dart';
import '../../widgets/news_list_item.dart';
import '../../widgets/section_header.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final newsProvider = context.watch<NewsViewModel>();
    final indexProvider = context.watch<IndexViewModel>();

    final selectedCategoryIndex = indexProvider.selectedCategoryIndex;
    final selectedCategoryName = newsProvider.categories[selectedCategoryIndex];

    final categoryNewsModel = newsProvider.getNewsByCategory(selectedCategoryName);
    final featuredNews = newsProvider.featuredNewsList;

    final featuredError = newsProvider.getErrorForCategory("featured");
    final listError = selectedCategoryName == "All"
        ? newsProvider.getErrorForCategory("recent")
        : newsProvider.getErrorForCategory(selectedCategoryName);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Good Morning",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      "Discover",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_none_rounded, size: 24.w),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removed standard subtitle because it's now in the header
            SizedBox(height: 24.h),

            SizedBox(
              height: 45.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: newsProvider.categories.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final category = newsProvider.categories[index];
                  return GestureDetector(
                    onTap: () {
                      context.read<IndexViewModel>().setSelectedCategoryIndex(index);
                      if (newsProvider.getNewsByCategory(category) == null) {
                        _fetchCategoryData(context, category);
                      }
                    },
                    child: CategoryPill(
                      text: category,
                      isSelected: selectedCategoryIndex == index,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 32.h),

            SectionHeader(
              title: "Featured",
              onTap: () {
                if (featuredNews != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeAllScreen(title: "Featured News", news: featuredNews),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16.h),

            if (featuredNews != null) ...[
              if (featuredNews.articles.isNotEmpty) ...[
                CarouselSlider.builder(
                  itemCount: featuredNews.articles.length > 5 ? 5 : featuredNews.articles.length,
                  itemBuilder: (context, index, realIndex) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailScreen(news: featuredNews.articles[index])),
                      ),
                      child: FeaturedNewsCard(news: featuredNews.articles[index]),
                    );
                  },
                  options: CarouselOptions(
                    initialPage: indexProvider.sliderIndex,
                    height: 420.h,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    viewportFraction: 1,
                    enableInfiniteScroll: true,
                    onPageChanged: (index, reason) {
                      indexProvider.setSliderIndex(index);
                    },
                  ),
                ),
                SizedBox(height: 15.h),
                Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: indexProvider.sliderIndex,
                    count: featuredNews.articles.length > 5 ? 5 : featuredNews.articles.length,
                    duration: const Duration(milliseconds: 500),
                    effect: WormEffect(
                      activeDotColor: isDark ? Colors.white : Colors.indigo,
                      dotColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      dotWidth: 14.w,
                      dotHeight: 14.w,
                    ),
                  ),
                ),
              ] else
                Text("No featured news available", style: TextStyle(fontSize: 14.sp)),
            ] else if (featuredError != null) ...[
              _buildErrorWidget(context, featuredError, () {
                context.read<NewsViewModel>().getNews(AppUrls.featured, "featured");
              }),
            ] else ...[
              Padding(
                padding: EdgeInsets.all(70.w),
                child: Center(child: CustomLoader(size: 40.w)),
              ),
            ],

            SizedBox(height: 32.h),

            if (selectedCategoryName == "All") ...[
              _buildNewsSection(
                context,
                title: "Recent News",
                data: newsProvider.recentNewsList,
                error: newsProvider.getErrorForCategory("recent"),
                onRetry: () => context.read<NewsViewModel>().getNews(AppUrls.recent, "recent"),
                isDark: isDark,
              ),
              _buildNewsSection(
                context,
                title: "Nation News",
                data: newsProvider.nationNews,
                error: newsProvider.getErrorForCategory("nation"),
                onRetry: () => context.read<NewsViewModel>().getNews(AppUrls.nation, "nation"),
                isDark: isDark,
              ),
              _buildNewsSection(
                context,
                title: "World News",
                data: newsProvider.worldNews,
                error: newsProvider.getErrorForCategory("world"),
                onRetry: () => context.read<NewsViewModel>().getNews(AppUrls.world, "world"),
                isDark: isDark,
              ),
            ] else ...[
              _buildNewsSection(
                context,
                title: "$selectedCategoryName News",
                data: categoryNewsModel,
                error: listError,
                onRetry: () => _fetchCategoryData(context, selectedCategoryName),
                isDark: isDark,
              ),
            ],

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  void _fetchCategoryData(BuildContext context, String category) {
    String url;
    String key = category.toLowerCase();

    switch (key) {
      case 'tech': url = AppUrls.technology; break;
      case 'health': url = AppUrls.health; break;
      case 'science': url = AppUrls.science; break;
      case 'gaming': url = AppUrls.gaming; break;
      case 'business': url = AppUrls.business; break;
      case 'entertainment': url = AppUrls.entertainment; break;
      case 'sports': url = AppUrls.sports; break;
      default: return;
    }

    context.read<NewsViewModel>().getNews(url, key);
  }

  Widget _buildNewsSection(
    BuildContext context, {
    required String title,
    required NewsResponseModel? data,
    required String? error,
    required VoidCallback onRetry,
    required bool isDark,
  }) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          onTap: () {
            if (data != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeeAllScreen(title: title, news: data),
                ),
              );
            }
          },
        ),
        SizedBox(height: 16.h),

        if (data != null) ...[
          if (data.articles.isEmpty)
            Center(child: Text("No articles found.", style: TextStyle(fontSize: 14.sp)))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.articles.length > 5 ? 5 : data.articles.length,
              separatorBuilder: (c, i) => Divider(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade500,
              ),
              itemBuilder: (context, index) {
                final news = data.articles[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(news: news)),
                  ),
                  child: NewsListItem(news: news),
                );
              },
            ),
        ] else if (error != null) ...[
          _buildErrorWidget(context, error, onRetry),
        ] else ...[
          Padding(
            padding: EdgeInsets.all(70.w),
            child: Center(child: CustomLoader(size: 40.w)),
          ),
        ],
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error, VoidCallback onRetry) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(13),
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(color: Colors.red.withAlpha(76)),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 30.w),
            SizedBox(height: 8.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade500, fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              ),
              child: Text("Retry", style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
      ),
    );
  }
}
