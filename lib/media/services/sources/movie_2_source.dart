import 'base_media_source.dart';

class Movie2Source extends BaseMediaSource {
  Movie2Source()
      : super(
          id: 'Movie_2',
          name: 'Nguồn Phim 2',
          type: 'movie',
          defaultUrl: 'https://motchillt.fm/',
          tag: 'Phim Vietsub',
          badge: 'Nhanh',
          status: 'Ổn định',
          allowedRoles: const ['Admin', 'Vip', 'User'],
        );

  @override
  List<String> getBlockedAdDomains() {
    return [
      'google-analytics.com',
      'doubleclick.net',
      'popads.net',
      'adsterra.com',
      'yo88',
      'popunder',
      'vsbet',
      'cm88',
      '3bet',
      'gem88',
      'sin88',
      'rikvip',
      'bom88',
      'adblock',
    ];
  }

  @override
  String getAdBlockScript() {
    return '''
      (function() {
        // 1. Cho phép popup Đăng nhập Google / OAuth hoạt động
        var originalOpen = window.open;
        window.open = function(url, name, specs) {
          var targetUrl = (url || '').toLowerCase();
          if (targetUrl.includes('accounts.google.com') || 
              targetUrl.includes('google.com/gsi') || 
              targetUrl.includes('oauth') || 
              targetUrl.includes('facebook.com')) {
            return originalOpen ? originalOpen.apply(this, arguments) : null;
          }
          return null;
        };

        // 2. Chặn click chuyển hướng quảng cáo (Bỏ qua Đăng nhập Google)
        var preventRedirect = function(e) {
          var target = e.target;
          while (target && target !== document) {
            if (target.tagName === 'A') {
              var href = (target.getAttribute('href') || '').toLowerCase();
              if (href.includes('accounts.google.com') || href.includes('google.com') || href.includes('oauth')) {
                return true;
              }
              if (href.includes('yo88') || href.includes('popunder') || href.includes('bet') || href.includes('88') || href.includes('adblock')) {
                e.preventDefault();
                e.stopPropagation();
                return false;
              }
            }
            target = target.parentNode;
          }
        };
        document.addEventListener('click', preventRedirect, true);

        // 3. CSS Ẩn triệt để nút Đóng QC & Icon AD Blocker nổi góc màn hình
        var style = document.createElement('style');
        style.innerHTML = `
          a[href*="yo88"], a[href*="bet"], a[href*="88"], a[href*="adblock"],
          img[src*="yo88"], img[src*="bet"], img[src*="88"], img[src*="adblock"],
          div[class*="banner"], div[id*="banner"],
          div[class*="adv"], div[id*="adv"],
          div[class*="tat-qc"], div[class*="dong-qc"],
          [class*="tat-qc"], [class*="dong-qc"],
          [id*="tat-qc"], [id*="dong-qc"],
          [class*="adblock"], [id*="adblock"],
          [class*="float-ad"], [id*="float-ad"],
          [class*="close-ad"], [id*="close-ad"] {
            display: none !important;
            visibility: hidden !important;
            opacity: 0 !important;
            pointer-events: none !important;
            height: 0 !important;
            width: 0 !important;
          }
        `;
        document.head.appendChild(style);

        // 4. Quét động quét đúng nút "Đóng QC X" và nút "AD Blocker" để ẩn an toàn
        setInterval(function() {
          var elements = document.querySelectorAll('div, a, span, img, iframe, button');
          elements.forEach(function(el) {
            var cls = (el.className || '').toString().toLowerCase();
            var id = (el.id || '').toLowerCase();
            var text = (el.innerText || el.textContent || '').toLowerCase().trim();
            var src = (el.src || '').toLowerCase();
            var href = (el.href || '').toLowerCase();

            // Tuyệt đối không can thiệp vào giao diện Đăng nhập / Google
            if (text.includes('google') || text.includes('đăng nhập') || text.includes('login') || 
                cls.includes('login') || id.includes('login') || cls.includes('google') || id.includes('google')) {
              return;
            }

            var isAdNode = false;

            // Nhận diện nút "Đóng QC X" nổi trên hình
            if (text.includes('đóng qc') || text.includes('tắt qc') || text.includes('dong qc') || text.includes('tat qc')) {
              isAdNode = true;
            }

            // Nhận diện icon tròn "AD Blocker" nổi ở góc
            if (text.includes('ad blocker') || text.includes('adblock') || 
                src.includes('adblock') || href.includes('adblock') || 
                cls.includes('adblock') || id.includes('adblock')) {
              isAdNode = true;
            }

            if (isAdNode) {
              // Ẩn thẻ bằng CSS style (Tránh dùng remove() gây lỗi crash Next.js)
              el.style.setProperty('display', 'none', 'important');
              el.style.setProperty('visibility', 'hidden', 'important');
              el.style.setProperty('opacity', '0', 'important');
              el.style.setProperty('pointer-events', 'none', 'important');

              // Tìm và ẩn luôn khung chứa nổi (fixed/absolute) nếu có
              var parent = el.closest('div[style*="fixed"]') || 
                           el.closest('div[style*="absolute"]') || 
                           el.closest('div[class*="qc"]') || 
                           el.closest('div[class*="ad"]');
              if (parent) {
                parent.style.setProperty('display', 'none', 'important');
                parent.style.setProperty('visibility', 'hidden', 'important');
                parent.style.setProperty('pointer-events', 'none', 'important');
              }
            }
          });
        }, 400);
      })();
    ''';
  }
}
