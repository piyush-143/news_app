import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widgets/custom_loader.dart';

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
    // Optimization: Initialize after the frame to ensure smooth navigation transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Small delay to let the page transition animation finish (prevents jank)
      Future.delayed(const Duration(milliseconds: 200), _initializeWebView);
    });
  }

  void _initializeWebView() {
    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  _loadingProgress = 0.1; // Start progress
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _loadingProgress = 1.0; // Complete
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (kDebugMode) {
                print("WebView Error: ${error.description}");
              }
              // Only block UI for critical main-frame errors
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
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. WebView (Content)
          if (_controller != null && !_hasError)
            WebViewWidget(controller: _controller!),

          // 2. Error State
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

          // 3. Initial Loading Spinner (Before Controller is ready)
          if (_controller == null && !_hasError)
            const Center(child: CustomLoader(size: 40)),

          // 4. Linear Progress Bar (During Page Load)
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
