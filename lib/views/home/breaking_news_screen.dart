import 'package:flutter/material.dart';
import 'package:news_app/view_models/news_view_model.dart';
import 'package:provider/provider.dart';

import '../../services/utils/app_urls.dart';
import '../../widgets/custom_loader.dart';
import 'detail_screen.dart';

/// A dedicated screen for "Breaking News" updates.
/// Uses a distinct red color scheme to emphasize urgency and separates content
/// from the main feed.
class BreakingScreen extends StatelessWidget {
  const BreakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch the provider to rebuild UI when new data arrives
    final newsProvider = context.watch<NewsViewModel>();

    // Check for errors specific to the 'breaking' category
    final breakingError = newsProvider.getErrorForCategory("breaking");

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: Row(
          children: [
            // Visual indicator (Red Dot) for "Live/Breaking" feel
            const Icon(Icons.circle, color: Colors.red, size: 12),
            const SizedBox(width: 8),
            Text("Breaking News", style: TextStyle(color: Colors.red.shade400)),
          ],
        ),
      ),
      // --- Conditional Rendering State Machine ---
      // 1. DATA EXISTS: Show List
      body: newsProvider.breakingNews != null
          ? ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: newsProvider.breakingNews!.articles.length,
              separatorBuilder: (c, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Divider(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade500,
                ),
              ),
              itemBuilder: (context, index) {
                // LOGIC: Accessing items in reverse order.
                // Assuming the API returns [Oldest ... Newest] or we want to flip the display sequence.
                final articleIndex =
                    newsProvider.breakingNews!.articles.length - 1 - index;
                final news = newsProvider.breakingNews!.articles[articleIndex];

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(news: news)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "LIVE UPDATES" Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(50),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "LIVE UPDATES",
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Headline
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle / Snippet
                      Text(
                        "Detailed coverage regarding ${news.source.name.toUpperCase()}...",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),

                      // Large Feature Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          news.image,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(
                            height: 200,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/no_img.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          // 2. ERROR STATE: Show Error Message & Retry Button
          : breakingError != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      breakingError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger fetch specifically for 'breaking' category
                      context.read<NewsViewModel>().getNews(
                        AppUrls.breaking,
                        "breaking",
                      );
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          // 3. LOADING STATE: Show Spinner
          : Center(child: CustomLoader(color: Colors.red.shade400, size: 50.0)),
    );
  }
}
