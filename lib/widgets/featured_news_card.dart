import 'package:flutter/material.dart';

import '../../models/news_response_model.dart';
import '../../services/utils/date_formatter.dart';
import '../../utils/size_config.dart';

class FeaturedNewsCard extends StatelessWidget {
  final Article news;

  const FeaturedNewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    // We don't necessarily need isDark here because we are placing text over an image,
    // so the text should generally be light to contrast with the dark gradient overlay.

    return Container(
      height: 280.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(24.w),
            child: Image.network(
              news.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/no_img.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          
          // 2. Gradient Overlay for Text Readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.w),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha(20),
                  Colors.black.withAlpha(180),
                  Colors.black.withAlpha(220),
                ],
                stops: const [0.0, 0.5, 0.8, 1.0],
              ),
            ),
          ),

          // 3. Text Content
          Positioned(
            bottom: 20.h,
            left: 20.w,
            right: 20.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category / Source Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Text(
                    news.source.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                
                // Title
                Text(
                  news.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                
                // Date & Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Colors.grey.shade300,
                      size: 14.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      DateFormatter.format(news.publishedAt),
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
