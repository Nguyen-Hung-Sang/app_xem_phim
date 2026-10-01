import 'base_media_source.dart';

class Movie1Source extends BaseMediaSource {
  Movie1Source()
      : super(
          id: 'Movie 1', // 👈 Đã sửa ID thành 'Movie 1' để đồng bộ với Firestore
          name: 'SaiGonPhim',
          type: 'movie',
          defaultUrl: 'https://saigonphim.net/',
          tag: 'Phim Vietsub',
          badge: 'Nhanh',
          status: 'Ổn định',
          allowedRoles: const [
            'Admin',
            'Vip',
            'User',
          ], // Chỉ cho phép Admin, Vip, và User truy cập
        );

  @override
  List<String> getBlockedAdDomains() {
    return [
      'google-analytics.com',
      'doubleclick.net',
      'popads.net',
      'adsterra.com',
    ];
  }

  @override
  String getAdBlockScript() {
    return '''
      (function() {
        // 1. Mở lại window.open DÀNH RIÊNG cho Đăng nhập Google / OAuth (Chặn popup quảng cáo)
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

        // 2. Chặn click chuyển hướng quảng cáo (Bỏ qua các liên kết Đăng nhập Google)
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

        // 3. CSS Ẩn triệt để banner quảng cáo & nút Đóng QC
        var style = document.createElement('style');
        style.innerHTML = `
          div[class*="qc"], div[id*="qc"],
          div[class*="adv"], div[id*="adv"],
          [class*="tat-qc"], [class*="dong-qc"],
          [id*="tat-qc"], [id*="dong-qc"] {
            display: none !important;
            visibility: hidden !important;
            opacity: 0 !important;
            pointer-events: none !important;
            height: 0 !important;
          }
        `;
        document.head.appendChild(style);

        // 4. Quét ẩn quảng cáo bằng CSS (Tránh xoá node làm rách cây DOM gây lỗi React/Next.js)
        setInterval(function() {
          var elements = document.querySelectorAll('div, a, span, img, iframe, button');
          elements.forEach(function(el) {
            var cls = (el.className || '').toString().toLowerCase();
            var id = (el.id || '').toLowerCase();
            var text = (el.innerText || el.textContent || '').toLowerCase().trim();

            // Bỏ qua tuyệt đối giao diện liên quan Đăng nhập / Google
            if (text.includes('google') || text.includes('đăng nhập') || text.includes('login') || 
                cls.includes('login') || id.includes('login') || cls.includes('google') || id.includes('google')) {
              return;
            }

            if (text === 'đóng qc' || text === 'tắt qc' || text === 'dong qc' || text === 'tat qc') {
              el.style.setProperty('display', 'none', 'important');
              el.style.setProperty('visibility', 'hidden', 'important');
              el.style.setProperty('opacity', '0', 'important');
              el.style.setProperty('pointer-events', 'none', 'important');
            }
          });
        }, 500);
      })();
    ''';
  }
}
