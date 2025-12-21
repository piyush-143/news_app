import 'package:flutter/material.dart';

import '../../models/news_response_model.dart';
import '../../widgets/news_list_item.dart';
import 'detail_screen.dart';

/// A generic, reusable screen to display a full vertical list of articles.
/// Used when the user clicks "See All" on sections like Featured, Sports, etc.
class SeeAllScreen extends StatelessWidget {
  final String title;
  final NewsResponseModel news;

  const SeeAllScreen({super.key, required this.title, required this.news});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // Ensure the back arrow is visible on both Light/Dark themes
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Optimization: We use the data passed via the constructor.
      // This avoids making a duplicate API call, making the screen load instantly.
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: news.articles.length,
        // Visual Logic: Automatically places a Divider between items, but not after the last one.
        separatorBuilder: (context, index) => Divider(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade500,
        ),
        itemBuilder: (context, index) {
          final article = news.articles[index];

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(news: article)),
            ),
            // Reusing the standard list item widget for consistency
            child: NewsListItem(news: article),
          );
        },
      ),
    );
  }
}
