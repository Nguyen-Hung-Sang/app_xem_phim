import 'base_media_source.dart';

class Movie3Source extends BaseMediaSource {
  Movie3Source()
      : super(
          id: 'Movie 3', // Khớp chính xác với Document ID "Movie 3" trên Firebase
          name: 'Hentaivn',
          type: 'movie',
          defaultUrl: 'https://hentaivs.org/',
          tag: 'Phim HD',
          badge: 'Tốc độ cao',
          status: 'Ổn định',
          allowedRoles: ['admin', 'vip'], // Phân quyền xem cho Admin và VIP
        );

  @override
  List<String> getBlockedAdDomains() {
    return [
      'popunder.net',
      'adnetwork.com',
      'doubleclick.net',
      'googlesyndication.com',
      'exoclick.com',
      'juicyads.com',
      'popads.net',
      'popcash.net',
    ];
  }

  @override
  String getAdBlockScript() {
    return '''
      (function() {
        // Vô hiệu hóa tính năng mở cửa sổ popup mới khi click
        window.open = function() { return null; };

        // Xóa các khung/iframe quảng cáo độc lập
        function cleanAds() {
          document.querySelectorAll('iframe').forEach(iframe => {
            const src = iframe.src || '';
            if (src.includes('ads') || src.includes('pop') || src.includes('exoclick') || src.includes('juicy')) {
              iframe.remove();
            }
          });
          document.querySelectorAll('.adsbygoogle, .popunder').forEach(el => el.remove());
        }

        cleanAds();
        setInterval(cleanAds, 1000);
      })();
    ''';
  }
}
