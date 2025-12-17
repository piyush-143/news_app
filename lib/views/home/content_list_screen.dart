import 'package:flutter/material.dart';
import 'package:news_app/views/home/detail_screen.dart';
import 'package:news_app/widgets/news_list_item.dart';

import '../../models/news_model.dart';

class ContentListScreen extends StatelessWidget {
  final String title;
  final List<Article> articles;
  final Widget? emptyState;
  final VoidCallback? onClear;

  const ContentListScreen({
    super.key,
    required this.title,
    required this.articles,
    this.emptyState,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (onClear != null && articles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: "Clear All",
              onPressed: onClear,
            ),
        ],
      ),
      body: articles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No articles found",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final news = articles[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(news: news)),
                  ),
                  child: NewsListItem(news: news),
                );
              },
            ),
    );
  }
}
