import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../services/utils/app_urls.dart';
import '../../view_models/index_view_model.dart';
import '../../view_models/news_view_model.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/featured_news_card.dart';
import '../../widgets/news_list_item.dart';
import '../../widgets/section_header.dart';
import 'detail_screen.dart';
import 'see_all_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(titleSpacing: 24, title: const Text("Discover")),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSubtitle(),
            SizedBox(height: 24),
            _CategorySelector(),
            SizedBox(height: 32),
            _FeaturedSection(),
            SizedBox(height: 32),
            _ContentSection(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// --- SUB-WIDGETS (Extracted for Performance) ---

class _HeaderSubtitle extends StatelessWidget {
  const _HeaderSubtitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      "News from around the world",
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector();

  // Optimization: Map lookups are O(1) and cleaner than if-else chains
  static final Map<String, String> _categoryUrls = {
    'tech': AppUrls.technology,
    'health': AppUrls.health,
    'science': AppUrls.science,
    'gaming': AppUrls.gaming,
    'business': AppUrls.business,
    'entertainment': AppUrls.entertainment,
    'sports': AppUrls.sports,
  };

  @override
  Widget build(BuildContext context) {
    // We only need the list of categories from the VM once (or rarely)
    final categories = context.read<NewsViewModel>().categories;

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final category = categories[index];

          // Optimization: Selector only rebuilds the specific pill if selection changes
          return Selector<IndexViewModel, int>(
            selector: (_, vm) => vm.selectedCategoryIndex,
            builder: (context, selectedIndex, _) {
              final isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () => _handleCategoryTap(context, index, category),
                child: CategoryPill(text: category, isSelected: isSelected),
              );
            },
          );
        },
      ),
    );
  }

  void _handleCategoryTap(BuildContext context, int index, String category) {
    final newsVM = context.read<NewsViewModel>();
    context.read<IndexViewModel>().setSelectedCategoryIndex(index);

    // Optimization: Lazy Load. Only fetch if we don't have data yet.
    if (newsVM.getNewsByCategory(category) == null) {
      final key = category.toLowerCase();
      final url = _categoryUrls[key]; // URL lookup

      if (url != null) {
        newsVM.getNews(url, key);
      } else if (key == 'all') {
        // 'All' maps to recent/general, usually fetched at startup,
        // but we can ensure it's loaded here if needed.
      }
    }
  }
}

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: "Featured",
          onTap: () {
            final data = context.read<NewsViewModel>().featuredNewsList;
            if (data != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SeeAllScreen(title: "Featured News", news: data),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 16),

        // Optimization: Consumer listens to changes in Featured News specifically
        Consumer<NewsViewModel>(
          builder: (context, newsVM, child) {
            final featuredNews = newsVM.featuredNewsList;
            final error = newsVM.getErrorForCategory("featured");
            final isLoading = newsVM.loading && featuredNews == null;

            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.all(70),
                child: Center(child: CustomLoader()),
              );
            }

            if (error != null) {
              return _ErrorPlaceholder(
                error: error,
                onRetry: () => newsVM.getNews(AppUrls.featured, "featured"),
              );
            }

            if (featuredNews == null || featuredNews.articles.isEmpty) {
              return const Text("No featured news available");
            }

            // Cap items at 5 for the slider
            final items = featuredNews.articles.take(5).toList();

            return Column(
              children: [
                CarouselSlider.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index, realIndex) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(news: items[index]),
                        ),
                      ),
                      child: FeaturedNewsCard(news: items[index]),
                    );
                  },
                  options: CarouselOptions(
                    // Optimization: Read initial index, don't listen to it here
                    initialPage: context.read<IndexViewModel>().sliderIndex,
                    height: 420,
                    autoPlay: true,
                    autoPlayInterval: const Duration(
                      seconds: 4,
                    ), // Slower is better for reading
                    viewportFraction: 1,
                    enableInfiniteScroll: true,
                    onPageChanged: (index, reason) {
                      context.read<IndexViewModel>().setSliderIndex(index);
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Separate widget for indicators to avoid rebuilding the heavy carousel
                _SliderIndicator(count: items.length),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SliderIndicator extends StatelessWidget {
  final int count;
  const _SliderIndicator({required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Optimization: Selector ensures ONLY the dots repaint when slider moves
    return Selector<IndexViewModel, int>(
      selector: (_, vm) => vm.sliderIndex,
      builder: (context, sliderIndex, _) {
        return Center(
          child: AnimatedSmoothIndicator(
            activeIndex: sliderIndex,
            count: count,
            duration: const Duration(milliseconds: 300),
            effect: WormEffect(
              activeDotColor: isDark ? Colors.white : Colors.indigo,
              dotColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              dotWidth: 10, // Smaller, cleaner dots
              dotHeight: 10,
            ),
          ),
        );
      },
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // We listen to the selected category index to switch views
    return Selector<IndexViewModel, int>(
      selector: (_, vm) => vm.selectedCategoryIndex,
      builder: (context, selectedIndex, _) {
        final newsVM = context.read<NewsViewModel>();
        final categoryName = newsVM.categories[selectedIndex];

        // "All" Tab shows multiple sections
        if (categoryName == "All") {
          return Column(
            children: [
              _SingleCategoryList(
                title: "Recent News",
                categoryKey: "recent",
                fetchUrl: AppUrls.recent,
                isDark: isDark,
              ),
              _SingleCategoryList(
                title: "Nation News",
                categoryKey: "nation",
                fetchUrl: AppUrls.nation,
                isDark: isDark,
              ),
              _SingleCategoryList(
                title: "World News",
                categoryKey: "world",
                fetchUrl: AppUrls.world,
                isDark: isDark,
              ),
            ],
          );
        }

        // Other Tabs show a single specific list
        // Note: The URL logic is handled in the onTap of the category pill,
        // so we just display the data here.
        return _SingleCategoryList(
          title: "$categoryName News",
          categoryKey: categoryName.toLowerCase(),
          // Fallback retry URL logic (simplified)
          fetchUrl: _getRetryUrl(categoryName),
          isDark: isDark,
        );
      },
    );
  }

  String _getRetryUrl(String categoryName) {
    final key = categoryName.toLowerCase();
    return _CategorySelector._categoryUrls[key] ?? AppUrls.recent;
  }
}

class _SingleCategoryList extends StatelessWidget {
  final String title;
  final String categoryKey;
  final String fetchUrl;
  final bool isDark;

  const _SingleCategoryList({
    required this.title,
    required this.categoryKey,
    required this.fetchUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsViewModel>(
      builder: (context, newsVM, _) {
        // Access data using the specific key
        // Note: NewsViewModel.getNewsByCategory handles key mapping
        final data = newsVM.getNewsByCategory(categoryKey);
        final error = newsVM.getErrorForCategory(categoryKey);

        // Loading state (local heuristic)
        final isLoading = data == null && error == null;

        return Column(
          children: [
            SectionHeader(
              title: title,
              onTap: () {
                if (data != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SeeAllScreen(title: title, news: data),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            if (data != null) ...[
              if (data.articles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text("No articles found.")),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.articles.take(5).length,
                  separatorBuilder: (c, i) => Divider(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                  itemBuilder: (context, index) {
                    final news = data.articles[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(news: news),
                        ),
                      ),
                      child: NewsListItem(news: news),
                    );
                  },
                ),
            ] else if (error != null) ...[
              _ErrorPlaceholder(
                error: error,
                onRetry: () => newsVM.getNews(fetchUrl, categoryKey),
              ),
            ] else if (isLoading) ...[
              const Padding(
                padding: EdgeInsets.all(50.0),
                child: Center(child: CustomLoader()),
              ),
            ],
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorPlaceholder({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
