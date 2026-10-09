import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
            _isLiked ? 'Đã lưu vào danh sách yêu thích' : 'Đã bỏ yêu thích',
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
            // Tiêm Script ngay từ thời điểm Document vừa bắt đầu tải
            initialUserScripts: UnmodifiableListView([
              UserScript(
                source: widget.source.getAdBlockScript(),
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
              ),
            ]),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading:
                  true, // Bật tính năng chặn nhảy trang
              useShouldInterceptRequest:
                  true, // Bật tính năng chặn request mạng
              javaScriptCanOpenWindowsAutomatically: true,
              supportMultipleWindows:
                  true, // Cho phép xử lý tạo window để hứng qua onCreateWindow
              userAgent: widget.source.getHeaders()['User-Agent'] ?? '',
              hardwareAcceleration: true,
              transparentBackground: false,
              allowsInlineMediaPlayback: true,
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            // Bắt và chuyển hướng các link mở cửa sổ mới về tab hiện tại nếu không phải quảng cáo
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

            // 1. CHẶN NẢY TRANG / MỞ TAB MỚI QUẢNG CÁO
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString().toLowerCase();

              // Chặn mở app ngoài (CH Play, Shopee, App Cá cược...)
              if (url.startsWith('intent://') ||
                  url.startsWith('market://') ||
                  url.startsWith('app://') ||
                  url.startsWith('taobaowebview://')) {
                debugPrint('[AdBlock] Đã chặn mở app ngoài: $url');
                return NavigationActionPolicy.CANCEL;
              }

              // Chặn theo từ khóa quảng cáo
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
                debugPrint('[AdBlock] Đã chặn nảy trang QC: $url');
                return NavigationActionPolicy.CANCEL;
              }

              // Chặn theo domain từ BaseMediaSource
              final blockedDomains = widget.source.getBlockedAdDomains();
              for (var domain in blockedDomains) {
                if (domain.isNotEmpty && url.contains(domain.toLowerCase())) {
                  debugPrint('[AdBlock] Đã chặn nảy trang tới domain QC: $url');
                  return NavigationActionPolicy.CANCEL;
                }
              }

              return NavigationActionPolicy.ALLOW;
            },

            // 2. CHẶN TẢI QUẢNG CÁO TỪ TẦNG MẠNG
            shouldInterceptRequest: (controller, request) async {
              final url = request.url.toString().toLowerCase();
              final blockedDomains = widget.source.getBlockedAdDomains();

              bool isAdRequest = false;

              // Kiểm tra xem request (iframe, js, css, ảnh) có gọi đến máy chủ quảng cáo không
              for (var domain in blockedDomains) {
                if (domain.isNotEmpty && url.contains(domain.toLowerCase())) {
                  isAdRequest = true;
                  break;
                }
              }

              // Chặn file script độc hại phổ biến
              if (url.contains('ads.js') ||
                  url.contains('popunder.js') ||
                  url.contains('beacon.min.js') ||
                  url.contains('splash.php')) {
                isAdRequest = true;
              }

              if (isAdRequest) {
                debugPrint('[AdBlock] Đã chặn tải tài nguyên QC: $url');
                // Trả về file rỗng -> Bóp chết đoạn mã quảng cáo không cho tải về máy
                return WebResourceResponse(
                  contentType: "text/plain",
                  data: Uint8List.fromList([]),
                );
              }

              return null; // Trả về null nghĩa là cho phép tải bình thường
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
