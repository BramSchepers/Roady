import 'package:flutter/foundation.dart';

import 'mobile_web_detector_stub.dart'
    if (dart.library.js_interop) 'mobile_web_detector_web.dart' as impl;

/// Returns true when running on web in a mobile/tablet browser.
/// Uses User Agent (Mobile, Android, iPhone, iPad, iPod).
/// On non-web platforms, always returns false.
bool isMobileUserAgent() {
  if (!kIsWeb) return false;
  return impl.isMobileUserAgent();
}
