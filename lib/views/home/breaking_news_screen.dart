import 'package:flutter/material.dart';
import 'package:news_app/view_models/news_view_model.dart';
import 'package:provider/provider.dart';

import '../../services/utils/app_urls.dart';
import '../../widgets/custom_loader.dart';
import 'detail_screen.dart';

class BreakingScreen extends StatefulWidget {
  const BreakingScreen({super.key});

  @override
  State<BreakingScreen> createState() => _BreakingScreenState();
}

class _BreakingScreenState extends State<BreakingScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newsProvider = context.watch<NewsViewModel>();
    final breakingError = newsProvider.getErrorForCategory("breaking");

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: Row(
          children: [
            const Icon(Icons.circle, color: Colors.red, size: 12),
            const SizedBox(width: 8),
            Text("Breaking News", style: TextStyle(color: Colors.red.shade400)),
          ],
        ),
      ),
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
                final news =
                    newsProvider.breakingNews!.articles[newsProvider
                            .breakingNews!
                            .articles
                            .length -
                        1 -
                        index];

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(news: news)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
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
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          news.image,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) =>
                              Container(height: 200, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : breakingError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.red.shade400,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Unable to load news",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      breakingError,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<NewsViewModel>().getNews(
                            AppUrls.breaking,
                            "breaking",
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          "Try Again",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(child: CustomLoader(color: Colors.red.shade400, size: 50.0)),
    );
  }
}
