import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../views/home/article_web_view.dart';

class UrlLaunchService {
  // Private constructor to prevent instantiation
  UrlLaunchService._();

  /// Opens the article in a customizable embedded WebView (Android/iOS)
  /// or falls back to external browser (Windows/Web/Linux/MacOS).
  static void openArticle(BuildContext context, String url, String title) {
    if (url.trim().isEmpty) {
      _showError(context, "Invalid article link.");
      return;
    }

    // OPTIMIZATION: Use defaultTargetPlatform instead of Theme.of(context).platform
    // This avoids an unnecessary Widget Tree lookup.
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleWebView(url: url, title: title),
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

      // Launch external application (Browser)
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          _showError(context, 'Could not open article link');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("UrlLaunchService Error: $e");
      }
      if (context.mounted) {
        _showError(context, 'Error launching URL');
      }
    }
  }

  // Helper method to reduce code duplication for SnackBars
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent, // Visual cue for error
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
