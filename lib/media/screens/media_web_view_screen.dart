import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/sources/base_media_source.dart';

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

  @override
  void initState() {
    super.initState();

    // Khởi tạo WebViewController với URL và Headers từ file nguồn
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    // Cấu hình User-Agent nếu được khai báo trong file nguồn
    final userAgent = widget.source.getHeaders()['User-Agent'];
    if (userAgent != null && userAgent.isNotEmpty) {
      _controller.setUserAgent(userAgent);
    }

    _controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });

            // BỔ SUNG: Bơm đoạn script chặn quảng cáo / cửa sổ bật nổi của riêng nguồn này
            final script = widget.source.getAdBlockScript();
            if (script.isNotEmpty) {
              await _controller.runJavaScript(script);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();

            // 1. Chặn các tham số popunder / chuyển trang tự động phát hiện trong log
            if (url.contains('popunder') || url.contains('yo88')) {
              return NavigationDecision.prevent;
            }

            // 2. Chặn các URL/Domain quảng cáo được khai báo trong file nguồn riêng
            final blockedDomains = widget.source.getBlockedAdDomains();
            for (var domain in blockedDomains) {
              if (domain.isNotEmpty && url.contains(domain.toLowerCase())) {
                return NavigationDecision.prevent; // Chặn quảng cáo
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
          // 1. Nút Quay lại trang web trước (Back)
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
          // 2. Nút Tiến tới trang web sau (Forward)
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
          // 3. Nút Tải lại trang (Reload)
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
