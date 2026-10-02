import 'base_media_source.dart';

class Movie4Source extends BaseMediaSource {
  Movie4Source()
      : super(
          id: 'Movie 4',
          name: 'Nguồn Phim 4',
          type: 'movie',
          defaultUrl: 'https://xnhau.soy/',
          tag: 'Phim HD',
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
    ];
  }

  @override
  String getAdBlockScript() {
    return '''
      (function() {
        const adDomainsRegex = /(badlandlispyippee|katawee|system-requirement|exoclick|juicyads|popads|popcash|adsterra|hilltopads|realsrv|cm88|qq88|new88|i9\.top|bet|casino)/i;

        // ==================================================================
        // 1. CHẶN KHỞI TẠO MÃ ĐỘC TỪ DOCUMENT.CREATEELEMENT VÀ SETATTRIBUTE
        // ==================================================================
        try {
          const origCreateElement = document.createElement;
          document.createElement = function(tagName, options) {
            const el = origCreateElement.call(document, tagName, options);
            if (tagName && (tagName.toLowerCase() === 'script' || tagName.toLowerCase() === 'iframe')) {
              const origSetAttribute = el.setAttribute;
              el.setAttribute = function(name, value) {
                if (name === 'src' && typeof value === 'string' && adDomainsRegex.test(value)) {
                  console.log('[Movie4 AdBlock] Chặn setAttribute src:', value);
                  return;
                }
                return origSetAttribute.call(this, name, value);
              };
            }
            return el;
          };
        } catch (e) {}

        // ==================================================================
        // 2. CHẶN GÁN SRC TRỰC TIẾP QUA SETTER PROTOTYPE
        // ==================================================================
        ['HTMLScriptElement', 'HTMLIFrameElement'].forEach(function(elemName) {
          if (window[elemName]) {
            const descriptor = Object.getOwnPropertyDescriptor(window[elemName].prototype, 'src');
            if (descriptor && descriptor.set) {
              const originalSet = descriptor.set;
              Object.defineProperty(window[elemName].prototype, 'src', {
                set: function(val) {
                  if (val && typeof val === 'string' && adDomainsRegex.test(val)) {
                    console.log('[Movie4 AdBlock] Chặn gán src:', val);
                    return;
                  }
                  return originalSet.call(this, val);
                },
                get: descriptor.get,
                configurable: true
              });
            }
          }
        });

        // ==================================================================
        // 3. CHẶN CHÈN ELEMENT QUA APPENDCHILD VÀ INSERTBEFORE
        // ==================================================================
        try {
          const origAppend = Element.prototype.appendChild;
          Element.prototype.appendChild = function(child) {
            if (child && child.tagName) {
              const tag = child.tagName.toLowerCase();
              if (tag === 'script' || tag === 'iframe') {
                const src = child.src || child.getAttribute('src') || '';
                if (adDomainsRegex.test(src)) {
                  console.log('[Movie4 AdBlock] Chặn appendChild:', src);
                  return child;
                }
              }
            }
            return origAppend.apply(this, arguments);
          };

          const origInsertBefore = Element.prototype.insertBefore;
          Element.prototype.insertBefore = function(newNode, referenceNode) {
            if (newNode && newNode.tagName) {
              const tag = newNode.tagName.toLowerCase();
              if (tag === 'script' || tag === 'iframe') {
                const src = newNode.src || newNode.getAttribute('src') || '';
                if (adDomainsRegex.test(src)) {
                  console.log('[Movie4 AdBlock] Chặn insertBefore:', src);
                  return newNode;
                }
              }
            }
            return origInsertBefore.apply(this, arguments);
          };
        } catch (e) {}

        // ==================================================================
        // 4. KHÓA WINDOW.OPEN VÀ CHẶN REPLACEMENT LOCATION
        // ==================================================================
        try {
          const dummyWin = { focus: function(){}, blur: function(){}, close: function(){}, postMessage: function(){} };
          Object.defineProperty(window, 'open', {
            value: function() { return dummyWin; },
            writable: false,
            configurable: false
          });

          const origReplace = location.replace;
          location.replace = function(url) {
            if (url && adDomainsRegex.test(url)) {
              console.log('[Movie4 AdBlock] Chặn location.replace:', url);
              return;
            }
            return origReplace.call(location, url);
          };
        } catch (e) {}

        // ==================================================================
        // 5. BẮT NẠP SỰ KIỆN BẤM LỠ CHUYỂN TRANG
        // ==================================================================
        const interceptAdClicks = function(e) {
          let target = e.target;
          while (target && target !== document) {
            if (target.tagName === 'A') {
              const href = target.getAttribute('href') || '';
              const isInternal = href.startsWith('/') || 
                                 href.startsWith('#') || 
                                 href.startsWith('?') || 
                                 href.includes(window.location.hostname) ||
                                 href.includes('xnhau') ||
                                 href.match(/(clip|video|album|photo|view|post|watch|page)/i);

              if (!isInternal && (href.startsWith('http') || href.startsWith('//'))) {
                e.preventDefault();
                e.stopPropagation();
                e.stopImmediatePropagation();
                return false;
              }
            }
            target = target.parentElement;
          }
        };

        ['click', 'touchstart', 'touchend', 'pointerdown'].forEach(evt => {
          window.addEventListener(evt, interceptAdClicks, true);
          document.addEventListener(evt, interceptAdClicks, true);
        });

        // ==================================================================
        // 6. QUÉT VÀ TRIỆT HẠ CÁC ELEMENT QUẢNG CÁO TỒN TẠI TRONG DOM
        // ==================================================================
        function cleanMovie4AdsOnly() {
          document.querySelectorAll('script, iframe').forEach(el => {
            if (!el) return;
            const src = el.src || el.getAttribute('src') || '';
            if (adDomainsRegex.test(src)) {
              if (el.parentNode) {
                el.parentNode.removeChild(el);
              }
            }
          });

          document.querySelectorAll('a[target]').forEach(a => {
            if (a) a.removeAttribute('target');
          });
        }

        cleanMovie4AdsOnly();
        setInterval(cleanMovie4AdsOnly, 150);
      })();
    ''';
  }
}
