import 'package:flutter/material.dart';
import 'package:news_app/view_models/news_view_model.dart';
import 'package:news_app/views/home/see_all_screen.dart';
import 'package:news_app/widgets/custom_loader.dart';
import 'package:provider/provider.dart';

import '../../models/news_model.dart';
import '../../services/utils/app_urls.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/featured_news_card.dart';
import '../../widgets/news_list_item.dart';
import '../../widgets/section_header.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    final newsProvider = context.watch<NewsViewModel>();

    final selectedCategoryIndex = newsProvider.selectedCategoryIndex;
    final selectedCategoryName = newsProvider.categories[selectedCategoryIndex];

    final categoryNewsModel = newsProvider.getNewsByCategory(
      selectedCategoryName,
    );
    final featuredNews = newsProvider.featuredNewsList;

    // Check specific errors
    final featuredError = newsProvider.getErrorForCategory("featured");
    // For the list section, check 'recent' if All, or specific category
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

            // --- Categories ---
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: newsProvider.categories.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final category = newsProvider.categories[index];
                  return GestureDetector(
                    onTap: () {
                      context.read<NewsViewModel>().setSelectedCategoryIndex(
                        index,
                      );

                      // Lazy fetch if needed
                      if (newsProvider.getNewsByCategory(category) == null) {
                        String url;
                        String key = category.toLowerCase();
                        // Simple mapping (Assuming keys match what's in AppUrls mostly)
                        if (key == 'tech') {
                          url = AppUrls.technology;
                        } else if (key == 'health') {
                          url = AppUrls.health;
                        } else if (key == 'science') {
                          url = AppUrls.science;
                        } else if (key == 'gaming') {
                          url = AppUrls.gaming;
                        } else if (key == 'business') {
                          url = AppUrls.business;
                        } else if (key == 'entertainment') {
                          url = AppUrls.entertainment;
                        } else if (key == 'sports') {
                          url = AppUrls.sports;
                        } else {
                          return;
                        } // 'All' uses recent

                        context.read<NewsViewModel>().getNews(url, key);
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

            // --- Featured Section ---
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

            if (featuredNews != null) ...[
              if (featuredNews.articles.isNotEmpty)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailScreen(news: featuredNews.articles.first),
                    ),
                  ),
                  child: FeaturedNewsCard(news: featuredNews.articles.first),
                )
              else
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

            // --- Sections ---
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
              _buildNewsSection(
                context,
                title: "$selectedCategoryName News",
                data: categoryNewsModel,
                error: listError,
                onRetry: () {
                  // Retry logic mirrors lazy fetch logic
                  String url;
                  String key = selectedCategoryName.toLowerCase();
                  if (key == 'tech') {
                    url = AppUrls.technology;
                  } else if (key == 'health') {
                    url = AppUrls.health;
                  } else if (key == 'science') {
                    url = AppUrls.science;
                  } else if (key == 'gaming') {
                    url = AppUrls.gaming;
                  } else if (key == 'business') {
                    url = AppUrls.business;
                  } else if (key == 'entertainment') {
                    url = AppUrls.entertainment;
                  } else if (key == 'sports') {
                    url = AppUrls.sports;
                  } else {
                    return;
                  }
                  context.read<NewsViewModel>().getNews(url, key);
                },
                isDark: isDark,
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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
        const SizedBox(height: 16),
        if (data != null) ...[
          if (data.articles.isEmpty)
            const Center(child: Text("No articles found."))
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
          const Padding(
            padding: EdgeInsets.all(70.0),
            child: Center(child: CustomLoader()),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

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
