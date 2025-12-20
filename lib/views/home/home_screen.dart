import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../models/news_model.dart';
import '../../services/utils/app_urls.dart';
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

    // Listen to changes in News and UI State
    final newsProvider = context.watch<NewsViewModel>();
    final indexProvider = context.watch<IndexViewModel>();

    // Determine currently selected category
    final selectedCategoryIndex = indexProvider.selectedCategoryIndex;
    final selectedCategoryName = newsProvider.categories[selectedCategoryIndex];

    // Get data for the selected category (might be null if not fetched yet)
    final categoryNewsModel = newsProvider.getNewsByCategory(
      selectedCategoryName,
    );
    final featuredNews = newsProvider.featuredNewsList;

    // Error Handling: Check specific errors for Featured vs Main List
    final featuredError = newsProvider.getErrorForCategory("featured");

    // If "All" is selected, we check 'recent' errors, otherwise the specific category error
    final listError = selectedCategoryName == "All"
        ? newsProvider.getErrorForCategory("recent")
        : newsProvider.getErrorForCategory(selectedCategoryName);

    return Scaffold(
      appBar: AppBar(titleSpacing: 24, title: const Text("Discover")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "News from around the world",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // --- 1. Horizontal Category Selector ---
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: newsProvider.categories.length,
                clipBehavior:
                    Clip.none, // Allow shadow/elevation to paint outside bounds
                itemBuilder: (context, index) {
                  final category = newsProvider.categories[index];
                  return GestureDetector(
                    onTap: () {
                      // Update UI selection immediately
                      context.read<IndexViewModel>().setSelectedCategoryIndex(
                        index,
                      );

                      // LAZY LOADING STRATEGY:
                      // We only fetch data if it hasn't been loaded yet.
                      // This saves bandwidth by not fetching "Sports" until the user actually clicks "Sports".
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
            const SizedBox(height: 32),

            // --- 2. Featured News Carousel ---
            SectionHeader(
              title: "Featured",
              onTap: () {
                if (featuredNews != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeAllScreen(
                        title: "Featured News",
                        news: featuredNews,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Logic: Data Exists ? Show Carousel : (Error ? Show Retry : Show Loader)
            if (featuredNews != null) ...[
              if (featuredNews.articles.isNotEmpty) ...[
                CarouselSlider.builder(
                  itemCount: featuredNews.articles.length > 5
                      ? 5
                      : featuredNews.articles.length,
                  itemBuilder: (context, index, realIndex) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailScreen(news: featuredNews.articles[index]),
                        ),
                      ),
                      child: FeaturedNewsCard(
                        news: featuredNews.articles[index],
                      ),
                    );
                  },
                  options: CarouselOptions(
                    initialPage: indexProvider.sliderIndex,
                    height: 420,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    viewportFraction: 1,
                    enableInfiniteScroll: true,
                    onPageChanged: (index, reason) {
                      indexProvider.setSliderIndex(index);
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: indexProvider.sliderIndex,
                    count: featuredNews.articles.length > 5
                        ? 5
                        : featuredNews.articles.length,
                    duration: const Duration(milliseconds: 500),
                    effect: WormEffect(
                      activeDotColor: isDark ? Colors.white : Colors.indigo,
                      dotColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      dotWidth: 17,
                      dotHeight: 17,
                    ),
                  ),
                ),
              ] else
                const Text("No featured news available"),
            ] else if (featuredError != null) ...[
              _buildErrorWidget(context, featuredError, () {
                context.read<NewsViewModel>().getNews(
                  AppUrls.featured,
                  "featured",
                );
              }),
            ] else ...[
              const Padding(
                padding: EdgeInsets.all(70),
                child: Center(child: CustomLoader()),
              ),
            ],

            const SizedBox(height: 32),

            // --- 3. News List Sections ---
            // If "All" is selected, we show a dashboard of multiple topics.
            // If a specific category is selected, we only show that list.
            if (selectedCategoryName == "All") ...[
              _buildNewsSection(
                context,
                title: "Recent News",
                data: newsProvider.recentNewsList,
                error: newsProvider.getErrorForCategory("recent"),
                onRetry: () => context.read<NewsViewModel>().getNews(
                  AppUrls.recent,
                  "recent",
                ),
                isDark: isDark,
              ),
              _buildNewsSection(
                context,
                title: "Nation News",
                data: newsProvider.nationNews,
                error: newsProvider.getErrorForCategory("nation"),
                onRetry: () => context.read<NewsViewModel>().getNews(
                  AppUrls.nation,
                  "nation",
                ),
                isDark: isDark,
              ),
              _buildNewsSection(
                context,
                title: "World News",
                data: newsProvider.worldNews,
                error: newsProvider.getErrorForCategory("world"),
                onRetry: () => context.read<NewsViewModel>().getNews(
                  AppUrls.world,
                  "world",
                ),
                isDark: isDark,
              ),
            ] else ...[
              // Specific Category View
              _buildNewsSection(
                context,
                title: "$selectedCategoryName News",
                data: categoryNewsModel,
                error: listError,
                onRetry: () =>
                    _fetchCategoryData(context, selectedCategoryName),
                isDark: isDark,
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Helper to map Category Names to API Endpoints and trigger fetch
  void _fetchCategoryData(BuildContext context, String category) {
    String url;
    String key = category.toLowerCase();

    switch (key) {
      case 'tech':
        url = AppUrls.technology;
        break;
      case 'health':
        url = AppUrls.health;
        break;
      case 'science':
        url = AppUrls.science;
        break;
      case 'gaming':
        url = AppUrls.gaming;
        break;
      case 'business':
        url = AppUrls.business;
        break;
      case 'entertainment':
        url = AppUrls.entertainment;
        break;
      case 'sports':
        url = AppUrls.sports;
        break;
      default:
        return; // 'All' is handled separately
    }

    context.read<NewsViewModel>().getNews(url, key);
  }

  /// Reusable widget to build a section with Header, List, Loader, or Error.
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
        const SizedBox(height: 16),

        if (data != null) ...[
          if (data.articles.isEmpty)
            const Center(child: Text("No articles found."))
          else
            ListView.separated(
              // IMPORTANT: shrinkWrap and NeverScrollable are required because
              // this ListView is inside the parent SingleChildScrollView.
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
          const Padding(
            padding: EdgeInsets.all(70.0),
            child: Center(child: CustomLoader()),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  /// Styled Error Widget with Retry Button
  Widget _buildErrorWidget(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 30),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade500, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
