import 'package:flutter/material.dart';
import 'package:news_app/view_models/news_view_model.dart';
import 'package:news_app/widgets/custom_loader.dart';
import 'package:provider/provider.dart';

import '../../services/utils/app_urls.dart';
import '../../services/utils/date_formatter.dart';
import 'detail_screen.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newsProvider = context.watch<NewsViewModel>();
    final trendingError = newsProvider.getErrorForCategory("trending");

    return Scaffold(
      appBar: AppBar(titleSpacing: 24, title: const Text("Trending News")),
      body: newsProvider.trendingNews != null
          ? ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              itemCount: newsProvider.trendingNews!.articles.length,
              separatorBuilder: (c, i) => Divider(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade500,
              ),
              itemBuilder: (context, index) {
                final news = newsProvider.trendingNews!.articles[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(news: news)),
                  ),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          "#${index + 1}",
                          style: TextStyle(
                            fontSize: 33,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade500,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.source.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${news.title} ...",
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                DateFormatter.format(news.publishedAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            news.image,
                            width: 90,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => Container(
                              width: 90,
                              height: 100,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/no_img.png"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : trendingError != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      trendingError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NewsViewModel>().getNews(
                        AppUrls.trending,
                        "trending",
                      );
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : Center(
              child: CustomLoader(
                color: isDark ? Colors.white : null,
                size: 50.0,
              ),
            ),
    );
  }
}
