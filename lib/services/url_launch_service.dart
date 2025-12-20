import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../views/home/article_web_view.dart';

/// A utility service to handle URL navigation across different platforms.
class UrlLaunchService {
  // Private constructor to enforce static-only usage
  UrlLaunchService._();

  /// Opens an article based on the platform:
  /// * **Android/iOS:** Opens inside the app using a WebView for a seamless experience.
  /// * **Web/Desktop:** Opens in the system's default external browser.
  static void openArticle(BuildContext context, String url, String title) {
    if (url.trim().isEmpty) {
      _showError(context, "Invalid article link.");
      return;
    }

    // Performance Note: `defaultTargetPlatform` is preferred over `Theme.of(context).platform`
    // here because it avoids an expensive lookup up the Widget Tree.
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

  /// Forces the URL to open in the external browser (e.g., Chrome, Safari).
  static Future<void> launchExternalUrl(
    BuildContext context,
    String url,
  ) async {
    try {
      final Uri uri = Uri.parse(url);

      // Mode `externalApplication` ensures we leave the app to open the browser,
      // rather than opening a partial in-app overlay.
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // Always check `mounted` before using `context` after an async operation (await)
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

  // Standardizes error feedback to the user
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
