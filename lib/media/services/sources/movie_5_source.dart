import 'base_media_source.dart';

class Movie5Source extends BaseMediaSource {
  Movie5Source()
      : super(
          id: 'Movie 5', // Khớp chính xác với Document ID "Movie 5" trên Firebase
          name: 'xHamster',
          type: 'movie',
          defaultUrl: 'https://vi.xhsocial.com/',
          tag: 'Phim HD',
          badge: 'Tốc độ cao',
          status: 'Ổn định',
          allowedRoles: ['admin', 'vip'], // Phân quyền xem cho Admin và VIP
        );

  // Kết nối trực tiếp mượt mà, không cần qua Proxy/VPN trung gian
  @override
  bool get isVpnRequired => false;

  @override
  List<String> getBlockedAdDomains() {
    return [
      'trafficjunky.com',
      'trafficjunky.net',
      'exoclick.com',
      'juicyads.com',
      'tsyndicate.com',
      'popads.net',
      'popcash.net',
      'adsterra.com',
      'hilltopads.com',
      'realsrv.com',
      'doubleclick.net',
      'googlesyndication.com',
      'cloudflareinsights.com',
      'ads',
      'popunder',
    ];
  }

  @override
  String getAdBlockScript() {
    return '''
      (function() {
        // 1. Khóa window.open thông minh: Cho phép link nội bộ xHamster, chặn popup quảng cáo ngoài
        try {
          window.open = function(url, target, features) {
            if (url && typeof url === 'string') {
              const isInternal = url.startsWith('/') || 
                                 url.startsWith('?') || 
                                 url.includes(window.location.hostname) || 
                                 url.includes('xhamster');
              if (isInternal) {
                window.location.href = url;
                return window;
              }
            }
            return null;
          };
        } catch(e) {}

        // 2. Chuyển tất cả thẻ <a> target="_blank" thành mở tại trang hiện tại
        function fixLinksAndTarget() {
          document.querySelectorAll('a').forEach(a => {
            if (a.getAttribute('target') === '_blank') {
              a.removeAttribute('target');
            }
          });
        }

        // 3. Xóa các khung/iframe quảng cáo độc lập
        function cleanAds() {
          document.querySelectorAll('iframe').forEach(iframe => {
            const src = iframe.src || iframe.getAttribute('src') || '';
            if (src.includes('ads') || src.includes('pop') || src.includes('trafficjunky') || src.includes('exoclick') || src.includes('juicy') || src.includes('tsyndicate')) {
              iframe.remove();
            }
          });
          document.querySelectorAll('.adsbygoogle, .popunder, [class*="ad-box"], [id*="popunder"], [class*="controller-ads"]').forEach(el => el.remove());
        }

        fixLinksAndTarget();
        cleanAds();

        setInterval(function() {
          fixLinksAndTarget();
          cleanAds();
        }, 400);
      })();
    ''';
  }
}
