import 'package:web/web.dart' as web;

/// Returns true if User Agent suggests mobile/tablet browser.
bool isMobileUserAgent() {
  try {
    final ua = web.window.navigator.userAgent;
    return RegExp(r'android|iphone|ipad|ipod|mobile', caseSensitive: false)
        .hasMatch(ua);
  } catch (_) {
    return false;
  }
}
