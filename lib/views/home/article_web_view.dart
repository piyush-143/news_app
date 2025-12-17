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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // FIX: Delay initialization to prevent "BLASTBufferQueue" errors during screen transition
    // This ensures the navigation animation finishes before the heavy SurfaceView loads.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _initializeWebView();
      }
    });
  }

  void _initializeWebView() {
    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final backgroundColor = isDark ? Colors.black : Colors.white;

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        // FIX: Use opaque background instead of transparent to fix buffer rendering issues
        ..setBackgroundColor(backgroundColor)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              if (kDebugMode) {
                print("WebView Error: ${error.description}");
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));

      // Trigger rebuild to show the WebView now that controller is ready
      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage =
            "Unable to initialize WebView.\nPlease restart the app fully to load native plugins.\n\nError: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        titleSpacing: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          : Stack(
              children: [
                // Only show WebViewWidget when controller is initialized
                if (_controller != null)
                  WebViewWidget(controller: _controller!),

                if (_isLoading || _controller == null)
                  const Center(child: CustomLoader(size: 40)),
              ],
            ),
    );
  }
}
