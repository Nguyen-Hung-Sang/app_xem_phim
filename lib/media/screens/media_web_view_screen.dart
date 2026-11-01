import 'dart:collection';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/sources/base_media_source.dart';
import '../services/like_service.dart';

class MediaWebViewScreen extends StatefulWidget {
  final BaseMediaSource source;
  const MediaWebViewScreen({
    super.key,
    required this.source,
  });

  @override
  State<MediaWebViewScreen> createState() => _MediaWebViewScreenState();
}

class _MediaWebViewScreenState extends State<MediaWebViewScreen> {
  InAppWebViewController? _controller;
  bool _isLoading = true;
  final LikeService _likeService = LikeService();
  String _currentUrl = '';
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.source.currentUrl;
    _checkLikeStatus(_currentUrl);
    _setupProxyIfNeeded();
  }

  Future<void> _setupProxyIfNeeded() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    if (widget.source.isVpnRequired &&
        widget.source.proxyUrl != null &&
        widget.source.proxyUrl!.isNotEmpty) {
      try {
        await ProxyController.instance().setProxyOverride(
          settings: ProxySettings(
            proxyRules: [
              ProxyRule(url: widget.source.proxyUrl!),
            ],
          ),
        );
      } catch (_) {}
    } else {
      try {
        await ProxyController.instance().clearProxyOverride();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    if (widget.source.isVpnRequired) {
      ProxyController.instance().clearProxyOverride();
    }
    super.dispose();
  }

  Future<void> _checkLikeStatus(String url) async {
    if (url.isEmpty) return;
    final liked = await _likeService.isLiked(url);
    if (mounted) {
      setState(() {
        _isLiked = liked;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_currentUrl.isEmpty) return;
    final isNowLiked = await _likeService.toggleLike(
      mediaId: _currentUrl,
      title: widget.source.name,
      url: _currentUrl,
    );
    if (mounted) {
      setState(() {
        _isLiked = isNowLiked;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLiked ? 'Đã lưu danh sách yêu thích' : 'Đã bỏ yêu thích',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121218),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181824),
        title: Text(
          widget.source.name,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.white,
            ),
            onPressed: _toggleLike,
            tooltip: _isLiked ? 'Bỏ yêu thích' : 'Thêm yêu thích',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () async {
              if (await _controller?.canGoBack() ?? false) {
                await _controller?.goBack();
              }
            },
            tooltip: 'Trang trước',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 20),
            onPressed: () async {
              if (await _controller?.canGoForward() ?? false) {
                await _controller?.goForward();
              }
            },
            tooltip: 'Trang sau',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller?.reload(),
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.source.currentUrl),
              headers: widget.source.getHeaders(),
            ),
            initialUserScripts: UnmodifiableListView([
              UserScript(
                source: widget.source.getAdBlockScript(),
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
              ),
            ]),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
              useShouldInterceptRequest: true,
              javaScriptCanOpenWindowsAutomatically: true,
              supportMultipleWindows: true,
              userAgent: widget.source.getHeaders()['User-Agent'] ?? '',
              hardwareAcceleration: true,
              transparentBackground: false,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              cacheEnabled: true,
              clearCache: false,
              useHybridComposition:
                  true, // Khắc phục triệt để lỗi treo UI Thread / Crash
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED);
            },
            onCreateWindow: (controller, createWindowAction) async {
              final url = createWindowAction.request.url;
              if (url != null) {
                final urlStr = url.toString().toLowerCase();
                final blockedDomains = widget.source.getBlockedAdDomains();
                bool isAd = blockedDomains.any(
                    (d) => d.isNotEmpty && urlStr.contains(d.toLowerCase()));
                if (!isAd) {
                  controller.loadUrl(urlRequest: URLRequest(url: url));
                }
              }
              return true;
            },
            onLoadStart: (controller, url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _currentUrl = url.toString();
                });
              }
              _checkLikeStatus(url.toString());
            },
            onLoadStop: (controller, url) async {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _currentUrl = url.toString();
                });
              }
              _checkLikeStatus(url.toString());
              final script = widget.source.getAdBlockScript();
              if (script.isNotEmpty) {
                await controller.evaluateJavascript(source: script);
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString().toLowerCase();
              if (url.startsWith('intent://') ||
                  url.startsWith('market://') ||
                  url.startsWith('app://') ||
                  url.startsWith('taobaowebview://')) {
                return NavigationActionPolicy.CANCEL;
              }
              final adKeywords = [
                'popunder',
                'yo88',
                'bet',
                'casino',
                'exoclick',
                'juicy',
                'shopee',
                'lazada',
                'pemsrv',
                'magsrv',
                'splash.php'
              ];
              if (adKeywords.any((keyword) => url.contains(keyword))) {
                return NavigationActionPolicy.CANCEL;
              }
              final blockedDomains = widget.source.getBlockedAdDomains();
              for (var domain in blockedDomains) {
                if (domain.isNotEmpty && url.contains(domain.toLowerCase())) {
                  return NavigationActionPolicy.CANCEL;
                }
              }
              return NavigationActionPolicy.ALLOW;
            },
            shouldInterceptRequest: (controller, request) async {
              final url = request.url.toString().toLowerCase();
              final blockedDomains = widget.source.getBlockedAdDomains();
              bool isAdRequest = false;
              for (var domain in blockedDomains) {
                if (domain.isNotEmpty && url.contains(domain.toLowerCase())) {
                  isAdRequest = true;
                  break;
                }
              }
              if (url.contains('ads.js') ||
                  url.contains('popunder.js') ||
                  url.contains('beacon.min.js') ||
                  url.contains('cloudflareinsights.com') ||
                  url.contains('splash.php')) {
                isAdRequest = true;
              }
              if (isAdRequest) {
                return WebResourceResponse(
                  contentType: "text/plain",
                  data: Uint8List.fromList([]),
                );
              }
              return null;
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ),
            ),
        ],
      ),
    );
  }
}
