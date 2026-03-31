import 'package:flutter/material.dart';
import 'package:news_app/services/url_launch_service.dart';

import '../../models/news_response_model.dart';
import '../../services/utils/date_formatter.dart';
import '../../utils/size_config.dart';

class DetailScreen extends StatelessWidget {
  final Article news;
  const DetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400.h,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                leading: Container(
                  margin: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(190),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.w),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        news.image,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/no_img.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black26,
                              Colors.transparent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: Radius.circular(30.w) == Radius.circular(30.w) ? BorderRadius.vertical(top: Radius.circular(30.w)) : BorderRadius.vertical(top: Radius.circular(30.w)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: themeColor.withAlpha(40),
                                borderRadius: BorderRadius.circular(20.w),
                              ),
                              child: Text(
                                news.source.name,
                                style: TextStyle(
                                  color: themeColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.access_time_rounded, size: 16.w, color: Colors.grey.shade500),
                            SizedBox(width: 6.w),
                            Text(
                              DateFormatter.format(news.publishedAt),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          news.title,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.3,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Divider(color: Colors.grey.shade400),
                        SizedBox(height: 24.h),
                        Text(
                          "${news.description}.",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          news.content,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                            height: 1.8,
                          ),
                        ),
                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 30.h,
            left: 24.w,
            right: 24.w,
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () => UrlLaunchService.openArticle(context, news.url, news.source.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: themeColor.withAlpha(80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Read Full Article", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward_rounded, size: 20.w),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
