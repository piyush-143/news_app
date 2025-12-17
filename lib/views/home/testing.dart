import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TestingWebView extends StatefulWidget {
  final String url;
  final String title;

  const TestingWebView({super.key, required this.url, required this.title});

  @override
  State<TestingWebView> createState() => _TestingWebViewState();
}

class _TestingWebViewState extends State<TestingWebView> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double progress = 0;
  bool _isLoading = true;

  // Ad Blocking Filters (Content Blockers)
  // This tells the WebView to hide elements that match these CSS selectors
  final List<ContentBlocker> contentBlockers = [
    ContentBlocker(
      trigger: ContentBlockerTrigger(
        urlFilter: ".*",
        resourceType: [
          ContentBlockerTriggerResourceType.IMAGE,
          ContentBlockerTriggerResourceType.STYLE_SHEET,
          ContentBlockerTriggerResourceType.SCRIPT,
          ContentBlockerTriggerResourceType.SVG_DOCUMENT,
          ContentBlockerTriggerResourceType.MEDIA,
          ContentBlockerTriggerResourceType.RAW,
        ],
      ),
      action: ContentBlockerAction(
        type: ContentBlockerActionType.CSS_DISPLAY_NONE,
        selector:
            ".ad-banner, .adsbygoogle, .google_ads, .ad-container, #ad, #banner-ad, .popup-ad, [id^='div-gpt-ad'], [class^='ad-']",
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => webViewController?.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),

            // 1. Apply the Ad Blocking Rules
            initialSettings: InAppWebViewSettings(
              contentBlockers: contentBlockers,
              isInspectable: kDebugMode,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              iframeAllow: "camera; microphone",
              iframeAllowFullscreen: true,
            ),

            onWebViewCreated: (controller) {
              webViewController = controller;
            },

            // 2. Track Loading Progress
            onProgressChanged: (controller, p) {
              setState(() {
                progress = p / 100;
                if (progress == 1) {
                  _isLoading = false;
                }
              });
            },

            // 3. Fallback Ad Removal (JavaScript Injection)
            // This runs after the page loads to clean up anything the Content Blocker missed
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(
                source: """
                var ads = document.querySelectorAll('.ad-banner, .adsbygoogle, [id^="google_ads"], .ad-container');
                ads.forEach(function(ad) {
                  ad.style.display = 'none';
                });
              """,
              );
              setState(() {
                _isLoading = false;
              });
            },
          ),

          // Loading Bar
          if (progress < 1.0)
            LinearProgressIndicator(value: progress, color: Colors.blueAccent),

          if (_isLoading && progress < 0.2)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
