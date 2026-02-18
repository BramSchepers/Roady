import 'dart:convert';
import 'dart:io';

// #region agent log
void debugLog(String location, String message,
    {String? hypothesisId, Map<String, dynamic>? data}) {
  try {
    final payload = <String, dynamic>{
      'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'location': location,
      'message': message,
      if (hypothesisId != null) 'hypothesisId': hypothesisId,
      if (data != null) 'data': data,
    };
    final path = r'c:\Users\brams\Desktop\Roady\.cursor\debug.log';
    File(path).writeAsStringSync('${jsonEncode(payload)}\n', mode: FileMode.append);
  } catch (_) {}
}
// #endregion
