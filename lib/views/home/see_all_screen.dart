import 'package:flutter/material.dart';

import '../../models/news_model.dart';
import '../../widgets/news_list_item.dart';
import 'detail_screen.dart';

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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: news.articles.length,
        separatorBuilder: (c, i) => Divider(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade500,
        ),
        itemBuilder: (context, index) {
          final article = news.articles[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(news: article)),
            ),
            child: NewsListItem(news: article),
          );
        },
      ),
    );
  }
}
