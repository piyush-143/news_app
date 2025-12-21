import 'package:flutter/material.dart';
import 'package:news_app/services/url_launch_service.dart';

import '../../models/news_response_model.dart';
import '../../services/utils/date_formatter.dart';

class DetailScreen extends StatelessWidget {
  final Article news;
  const DetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    // Extract theme values once for cleaner code below
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      // Using a Stack to float the "Read Article" button over the scrollable content
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight:
                    400, // Make the image tall for an immersive feel
                pinned: true, // Keep the back button visible when scrolled up
                stretch: true, // Allow the image to "zoom in" when pulling down
                backgroundColor: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,

                // Custom Back Button with background for visibility on any image
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(190),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                      // The News Image
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
                      // Gradient Overlay: Ensures the top status bar area is legible
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

              // --- Article Content Section ---
              SliverToBoxAdapter(
                // VISUAL TRICK: We shift the container UP by 20 pixels (`offset: -20`).
                // This creates the effect of the white content sheet overlapping
                // the bottom of the image with rounded corners.
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      // Shadow adds depth between the sheet and the image
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26, // Subtle shadow
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Source Name & Date ---
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: themeColor.withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                news.source.name,
                                style: TextStyle(
                                  color: themeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormatter.format(news.publishedAt),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // --- Headline ---
                        Text(
                          news.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.3,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Divider(color: Colors.grey.shade400),
                        const SizedBox(height: 24),

                        // --- Description (Lead Paragraph) ---
                        // Styled in italics/bold to differentiate from body text
                        Text(
                          "${news.description}.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade800,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Body Content ---
                        // API Note: Most free news APIs truncate this (e.g., "... [+1200 chars]").
                        // That is why the "Read Full Article" button below is necessary.
                        Text(
                          news.content,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                            height: 1.8,
                          ),
                        ),

                        const SizedBox(
                          height: 100,
                        ), // Extra space so FAB doesn't cover text
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- Bottom Floating Action Button ---
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => UrlLaunchService.openArticle(
                  context,
                  news.url,
                  news.source.name,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: themeColor.withAlpha(80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Read Full Article",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
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
