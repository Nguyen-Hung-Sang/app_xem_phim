import 'base_media_source.dart';

class Picture3Source extends BaseMediaSource {
  Picture3Source()
      : super(
          id: 'Picture 3',
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
      // Google Ads
      'doubleclick.net',
      'googlesyndication.com',
      'googleadservices.com',
      'google-analytics.com',

      // Advertising networks
      'exoclick.com',
      'juicyads.com',
      'popads.net',
      'popcash.net',
      'popunder.net',
      'adnetwork.com',
      'faphouse2.com',

      // Other common advertising domains
      'adsterra.com',
      'propellerads.com',
      'onclickads.net',
      'trafficjunky.net',
      'hilltopads.net',
    ];
  }

  @override
  String getAdBlockScript() {
    return r'''
(function() {

  // =====================================================
  // 1. PREVENT MULTIPLE INSTALLATIONS
  // =====================================================

  if (window.__buonduaAdBlockInstalled) return;

  window.__buonduaAdBlockInstalled = true;


  // =====================================================
  // 2. BLOCKED DOMAINS
  // =====================================================

  const blockedDomains = [
    'doubleclick.net',
    'googlesyndication.com',
    'googleadservices.com',
    'google-analytics.com',
    'exoclick.com',
    'juicyads.com',
    'popads.net',
    'popcash.net',
    'popunder.net',
    'adnetwork.com',
    'faphouse2.com',
    'adsterra.com',
    'propellerads.com',
    'onclickads.net',
    'trafficjunky.net',
    'hilltopads.net'
  ];


  // =====================================================
  // 3. CHECK AD URL
  // =====================================================

  function isBlockedUrl(url) {
    if (!url) return false;

    try {
      const hostname = new URL(url, location.href)
        .hostname
        .toLowerCase();

      return blockedDomains.some(function(domain) {
        return hostname === domain ||
               hostname.endsWith('.' + domain);
      });

    } catch(e) {
      return false;
    }
  }


  // =====================================================
  // 4. BLOCK POPUP
  // =====================================================

  const blockedOpen = function() {
    return null;
  };

  try {
    Object.defineProperty(window, 'open', {
      value: blockedOpen,
      writable: false,
      configurable: false
    });
  } catch(e) {
    window.open = blockedOpen;
  }


  // =====================================================
  // 5. BLOCK AD LINKS
  // =====================================================

  document.addEventListener('click', function(e) {

    let target = e.target;

    while (target && target !== document) {

      if (target.tagName === 'A') {

        const href = target.href || '';

        if (isBlockedUrl(href)) {

          e.preventDefault();
          e.stopImmediatePropagation();

          return false;
        }
      }

      target = target.parentElement;
    }

  }, true);


  // =====================================================
  // 6. BLOCK FORM SUBMISSION TO AD DOMAINS
  // =====================================================

  document.addEventListener('submit', function(e) {

    const form = e.target;

    if (form && form.action && isBlockedUrl(form.action)) {

      e.preventDefault();
      e.stopImmediatePropagation();

    }

  }, true);


  // =====================================================
  // 7. HIDE COMMON AD ELEMENTS
  // =====================================================

  const adStyle = document.createElement('style');

  adStyle.textContent = `

    /* Google Ads */
    iframe[src*="doubleclick"],
    iframe[src*="googlesyndication"],
    iframe[src*="googleadservices"],

    /* Advertising networks */
    iframe[src*="exoclick"],
    iframe[src*="juicyads"],
    iframe[src*="popads"],
    iframe[src*="popcash"],
    iframe[src*="popunder"],
    iframe[src*="adsterra"],
    iframe[src*="propellerads"],

    /* Common advertising classes */
    .adsbygoogle,
    [class*="advertisement"],
    [id*="advertisement"],
    [class*="ad-container"],
    [id*="ad-container"],
    [class*="ads-container"],
    [id*="ads-container"],
    [class*="sponsored-ad"],
    [id*="sponsored-ad"] {

      display: none !important;
      visibility: hidden !important;
      pointer-events: none !important;
    }

  `;

  function insertAdStyle() {

    if (!document.head) return;

    if (!document.getElementById('__buondua_ad_style')) {

      adStyle.id = '__buondua_ad_style';

      document.head.appendChild(adStyle);
    }
  }


  // =====================================================
  // 8. REMOVE SPONSORED ADS SECTION
  // =====================================================

  function removeSponsoredAds() {

    const elements = document.querySelectorAll(
      'h1,h2,h3,h4,h5,h6,p,div,span,strong'
    );

    elements.forEach(function(el) {

      if (!el.isConnected) return;

      // Only process short text labels
      if (el.children.length > 5) return;

      const text = (el.innerText || '')
        .trim()
        .toLowerCase();

      if (
        text !== 'sponsored ads' &&
        text !== 'sponsored advertisement' &&
        text !== 'sponsored advertisements'
      ) {
        return;
      }

      // Find the closest advertisement container
      let parent = el;

      for (let i = 0; i < 5; i++) {

        if (!parent.parentElement) break;

        parent = parent.parentElement;

        const images = parent.querySelectorAll('img');

        const links = parent.querySelectorAll('a');

        // Only hide a small advertising section
        if (
          images.length >= 2 &&
          images.length <= 20 &&
          parent.getBoundingClientRect().height < 700
        ) {

          parent.style.setProperty(
            'display',
            'none',
            'important'
          );

          return;
        }
      }

      // If container cannot be identified,
      // hide only the heading
      el.style.setProperty(
        'display',
        'none',
        'important'
      );

    });
  }


  // =====================================================
  // 9. REMOVE KNOWN AD IFRAMES
  // =====================================================

  function removeAdIframes() {

    document.querySelectorAll('iframe').forEach(function(iframe) {

      const src = iframe.src || '';

      if (isBlockedUrl(src)) {
        iframe.remove();
      }

    });
  }


  // =====================================================
  // 10. CLEANUP FUNCTION
  // =====================================================

  function cleanAds() {

    insertAdStyle();

    removeSponsoredAds();

    removeAdIframes();

  }


  // =====================================================
  // 11. OBSERVE DYNAMIC CONTENT
  // =====================================================

  let timer = null;

  const observer = new MutationObserver(function() {

    if (timer !== null) return;

    timer = setTimeout(function() {

      timer = null;

      cleanAds();

    }, 300);

  });


  // =====================================================
  // 12. INITIALIZE
  // =====================================================

  function initialize() {

    if (!document.body) return;

    cleanAds();

    observer.observe(document.body, {

      childList: true,

      subtree: true

    });

  }


  if (document.readyState === 'loading') {

    document.addEventListener(
      'DOMContentLoaded',
      initialize,
      { once: true }
    );

  } else {

    initialize();

  }

}
)
();
''';
  }
}
