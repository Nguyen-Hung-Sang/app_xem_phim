import 'base_media_source.dart';

class Picture2Source extends BaseMediaSource {
  Picture2Source()
      : super(
          id: 'Picture 2', // Khớp chính xác với Document ID trên Firebase
          name: 'knit',
          type: 'picture',
          defaultUrl: 'https://xx.knit.bid/vi/', // Cập nhật URL mới
          tag: 'Hình Ảnh HD',
          badge: 'Ổn định',
          status: 'Ổn định',
          allowedRoles: ['admin', 'vip'], // Chỉ Admin và VIP mới xem được
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
      'hilltopads.com',
      'monetag.com',
      'adsterra.com',
      'realsrv.com',
    ];
  }

  @override
  String getAdBlockScript() {
    return '''
      (function() {
        // 1. Chặn hoàn toàn Popup / Popunder khi chạm vào màn hình
        window.open = function() { return null; };

        // 2. Chèn CSS diệt iframe quảng cáo & các khối banner tài trợ (Chỉ chặn iframe quảng cáo, không chặn iframe hệ thống/xác thực)
        if (!document.getElementById('fix-adblock-style')) {
          const style = document.createElement('style');
          style.id = 'fix-adblock-style';
          style.textContent = `
            iframe[src*="ad"],
            iframe[src*="pop"],
            iframe[src*="exoclick"],
            iframe[src*="juicyads"],
            .adsbygoogle,
            .popunder,
            div[class*="sponsor"],
            div[id*="sponsor"],
            a[href*="exoclick"],
            a[href*="juicyads"],
            a[href*="stripchat"],
            a[href*="realsrv"] {
              display: none !important;
              visibility: hidden !important;
              opacity: 0 !important;
              pointer-events: none !important;
              height: 0 !important;
            }
          `;
          if (document.head) document.head.appendChild(style);
        }

        function cleanAdsAndLoadThumbnails() {
          // 3. TẢI ẢNH BÀI VIẾT (LAZY-LOAD): Ép tải link ảnh thực tế
          document.querySelectorAll('img').forEach(img => {
            if (img.closest('iframe')) return;

            const realSrc = img.getAttribute('data-src') || 
                            img.getAttribute('data-original') || 
                            img.getAttribute('data-lazy-src') ||
                            img.getAttribute('srcset');

            if (realSrc) {
              const url = realSrc.split(' ')[0].trim();
              if (url && (img.src === '' || img.src.includes('data:image') || img.naturalWidth === 0)) {
                img.src = url;
              }
            }

            // Đảm bảo ảnh luôn hiển thị
            img.style.setProperty('display', 'block', 'important');
            img.style.setProperty('opacity', '1', 'important');
            img.style.setProperty('visibility', 'visible', 'important');
          });

          // 4. DIỆT QUẢNG CÁO NỔI DÍNH ĐÁY MÀN HÌNH (GIỮ LẠI CỬA SỔ HỎI TUỔI & THÔNG BÁO VIP)
          document.querySelectorAll('div, section, aside, body > *').forEach(el => {
            if (el.tagName === 'NAV' || el.tagName === 'HEADER' || el.querySelector('nav')) return;
            if (el.querySelector('article') || el.classList.contains('post') || el.classList.contains('item')) return;

            // Bổ sung kiểm tra: Nếu chứa nội dung xác nhận tuổi, VIP, nút bấm chọn hoặc thuộc tính Modal thì BỎ QUA không xóa
            const text = (el.innerText || el.textContent || '').toLowerCase();
            const isAgeOrVipModal = text.includes('tuổi') || 
                                    text.includes('age') || 
                                    text.includes('18') || 
                                    text.includes('vip') || 
                                    text.includes('xác nhận') || 
                                    text.includes('thời gian') ||
                                    text.includes('đồng ý') ||
                                    text.includes('confirm') ||
                                    text.includes('agree') ||
                                    text.includes('enter') ||
                                    el.querySelector('button') !== null ||
                                    el.querySelector('input') !== null ||
                                    el.classList.contains('modal') ||
                                    el.classList.contains('dialog') ||
                                    el.getAttribute('role') === 'dialog';

            if (isAgeOrVipModal) return;

            const style = window.getComputedStyle(el);
            if (style.position === 'fixed' || style.position === 'sticky') {
              if (el.clientWidth < 70 && el.clientHeight < 70) return;

              el.style.setProperty('display', 'none', 'important');
              el.remove();
            }
          });

          // 5. ẨN KHUNG CHỨA DÒNG CHỮ "Sponsored ads"
          document.querySelectorAll('div, p, span').forEach(el => {
            if (el.children.length === 0 && el.textContent.trim().toLowerCase().includes('sponsored')) {
              let parent = el.parentElement;
              if (parent && !parent.querySelector('article')) {
                parent.style.setProperty('display', 'none', 'important');
              }
            }
          });
        }

        // Chạy liên tục để chặn quảng cáo tải chậm
        cleanAdsAndLoadThumbnails();
        setInterval(cleanAdsAndLoadThumbnails, 500);
      })();
    ''';
  }
}
