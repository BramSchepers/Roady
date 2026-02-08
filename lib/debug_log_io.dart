// #region agent log
import 'dart:convert';
import 'dart:io';

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
  final line = '${jsonEncode(payload)}\n';
  debugPrint('DEBUG $line');
  try {
    const path = r'c:\Users\brams\Desktop\Roady\.cursor\debug.log';
    File(path).writeAsStringSync(line, mode: FileMode.append);
  } catch (_) {}
}
// #endregion
