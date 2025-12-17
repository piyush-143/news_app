import 'package:flutter/material.dart';

import '../models/news_model.dart';
import '../services/utils/date_formatter.dart';

class NewsListItem extends StatelessWidget {
  final Article news;

  const NewsListItem({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, top: 10),

      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              news.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) =>
                  Container(width: 100, height: 100, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.source.name, // Ideally pass this or derive from source
                  style: TextStyle(
                    color: Colors.blueAccent.shade200,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  news.title + "...",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormatter.format(news.publishedAt),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
