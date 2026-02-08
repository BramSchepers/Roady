// #region agent log
import 'dart:convert';

import 'package:flutter/foundation.dart';

void debugLog(String location, String message, Map<String, dynamic> data,
    String hypothesisId) {
  final payload = {
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };
  debugPrint('DEBUG ${jsonEncode(payload)}');
}
// #endregion
