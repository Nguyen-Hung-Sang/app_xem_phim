import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  late final WebViewController _controller;
  bool _isLoading = true;

  final LikeService _likeService = LikeService();
  String _currentUrl = '';
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.source.currentUrl;
    _checkLikeStatus(_currentUrl);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    final userAgent = widget.source.getHeaders()['User-Agent'];
    if (userAgent != null && userAgent.isNotEmpty) {
      _controller.setUserAgent(userAgent);
    }

    _controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _currentUrl = url;
              });
            }
            _checkLikeStatus(url);
          },
          onPageFinished: (String url) async {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _currentUrl = url;
              });
            }
            _checkLikeStatus(url);

            final script = widget.source.getAdBlockScript();
            if (script.isNotEmpty) {
              await _controller.runJavaScript(script);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();
            if (url.contains('popunder') || url.contains('yo88')) {
              return NavigationDecision.prevent;
            }

            final blockedDomains = widget.source.getBlockedAdDomains();
            for (var domain in blockedDomains) {
              if (domain.isNotEmpty && url.contains(domain.toLowerCase())) {
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.source.currentUrl),
        headers: widget.source.getHeaders(),
      );
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
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              }
            },
            tooltip: 'Trang trước',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 20),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                await _controller.goForward();
              }
            },
            tooltip: 'Trang sau',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.reload(),
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
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
