import 'base_media_source.dart';

class Picture3Source extends BaseMediaSource {
  Picture3Source()
      : super(
          id: 'Picture 3', // Khớp chính xác với Document ID "Picture 3" trên Firebase
          name: 'Buondua',
          type: 'picture',
          defaultUrl: 'https://buondua.com/',
          tag: 'Ảnh HD',
          badge: 'Tốc độ cao',
          status: 'Ổn định',
          allowedRoles: ['admin', 'vip'],
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
      'adsterra.com',
      'hilltopads.com',
      'realsrv.com',
      'katawee.net',
      'badlandlispyippee.com',
      'system-requirement',
      'cm88',
      'qq88',
      'new88',
      'i9.top',
      'faphouse2.com',
      'magsrv.com',
      'marzaent.com',
      'orbsrv.com',
      'pemsrv.com',
      'cloudflareinsights.com',
    ];
  }

  @override
  String getAdBlockScript() {
    return '''
      (function() {
        // 1. Khóa window.open thông minh: Cho phép link nội bộ Buondua, chặn link quảng cáo ngoài
        try {
          window.open = function(url, target, features) {
            if (url && typeof url === 'string') {
              const isInternal = url.startsWith('/') || 
                                 url.startsWith('?') || 
                                 url.includes(window.location.hostname) || 
                                 url.includes('buondua');
              if (isInternal) {
                window.location.href = url;
                return window;
              }
            }
            return null; // Chặn popup quảng cáo
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

        // 3. Xóa iframe & banner quảng cáo Sponsored ads
        function cleanAdElements() {
          document.querySelectorAll('iframe').forEach(iframe => {
            const src = iframe.src || iframe.getAttribute('src') || '';
            if (src.includes('magsrv') || src.includes('pemsrv') || src.includes('exoclick') || src.includes('juicy') || src.includes('pop')) {
              iframe.remove();
            }
          });

          // Quét xóa khối chứa chữ "Sponsored ads"
          const walker = document.createTreeWalker(document.body || document.documentElement, NodeFilter.SHOW_TEXT, null, false);
          let node;
          while (node = walker.nextNode()) {
            if (node.nodeValue && node.nodeValue.trim() === 'Sponsored ads') {
              let parent = node.parentElement;
              for (let i = 0; i < 3 && parent && parent !== document.body; i++) {
                if (parent.tagName === 'DIV' || parent.tagName === 'SECTION') {
                  parent.style.display = 'none';
                  break;
                }
                parent = parent.parentElement;
              }
            }
          }
        }

        // Thực thi liên tục
        fixLinksAndTarget();
        cleanAdElements();

        setInterval(function() {
          fixLinksAndTarget();
          cleanAdElements();
        }, 300);
      })();
    ''';
  }
}
