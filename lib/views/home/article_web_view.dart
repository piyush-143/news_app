import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widgets/custom_loader.dart';

/// A dedicated screen to view news articles within the app.
/// Uses a WebView to render the original source content.
class ArticleWebView extends StatefulWidget {
  final String url;
  final String title;

  const ArticleWebView({super.key, required this.url, required this.title});

  @override
  State<ArticleWebView> createState() => _ArticleWebViewState();
}

class _ArticleWebViewState extends State<ArticleWebView> {
  WebViewController? _controller;
  double _loadingProgress = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // PERFORMANCE OPTIMIZATION:
    // WebViews are heavy widgets. Initializing them immediately can cause the
    // navigation transition (push animation) to stutter or freeze.
    // We wait for the frame to finish, plus a tiny delay, to let the animation complete first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), _initializeWebView);
    });
  }

  void _initializeWebView() {
    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      // Match WebView background to the app theme to avoid a white flash in dark mode
      final backgroundColor = isDark ? Colors.black : Colors.white;

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(backgroundColor)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _loadingProgress = progress / 100;
                });
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _hasError = false;
                  _loadingProgress =
                      0.1; // Jump-start the bar so user sees activity
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _loadingProgress = 1.0; // Hide the bar
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (kDebugMode) {
                print("WebView Error: ${error.description}");
              }
              // ERROR HANDLING STRATEGY:
              // Only block the UI for critical failures (No Internet, DNS fail).
              // We ignore minor errors (like a missing ad image or tracking script)
              // so the user can still read the text.
              if (error.errorType == WebResourceErrorType.connect ||
                  error.errorType == WebResourceErrorType.hostLookup ||
                  error.errorType == WebResourceErrorType.timeout) {
                if (mounted) setState(() => _hasError = true);
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));

      if (mounted) {
        setState(() => _controller = controller);
      }
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // Custom Title Layout: Shows Title + URL Domain
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16)),
            Text(
              widget.url,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        titleSpacing: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Refresh Button (Useful if page stalls)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller?.reload();
            },
          ),
        ],
      ),
      // Using Stack to layer the loading indicator ON TOP of the WebView
      body: Stack(
        children: [
          // 1. Content Layer
          if (_controller != null && !_hasError)
            WebViewWidget(controller: _controller!),

          // 2. Error Layer
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  const Text("Failed to load article"),
                  TextButton(
                    onPressed: () => _controller?.reload(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),

          // 3. Initialization Spinner (Waiting for Controller)
          if (_controller == null && !_hasError)
            const Center(child: CustomLoader(size: 40)),

          // 4. Progress Bar Layer (Topmost)
          if (_loadingProgress < 1.0 && _controller != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress,
                backgroundColor: Colors.transparent,
                color: Colors.indigo,
                minHeight: 3,
              ),
            ),
        ],
      ),
    );
  }
}
