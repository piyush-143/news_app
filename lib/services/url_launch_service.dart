import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../views/home/article_web_view.dart';

class UrlLaunchService {
  /// Opens the article in a customizable embedded WebView (Android/iOS)
  /// or falls back to external browser (Windows/Web).
  static void openArticle(BuildContext context, String url, String title) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleWebView(url: url, title: title),
          // builder: (context) => TestingWebView(url: url, title: title),
        ),
      );
    } else {
      launchExternalUrl(context, url);
    }
  }

  /// Launches the URL in the default external browser
  static Future<void> launchExternalUrl(
    BuildContext context,
    String url,
  ) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open article link')),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error launching URL: $e");
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error launching URL')));
      }
    }
  }
}
