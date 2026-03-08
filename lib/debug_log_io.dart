import 'dart:convert';
import 'dart:io';

void writeDebugLog(String location, String message, Map<String, dynamic> data, String hypothesisId) {
  try {
    final payload = {
      'sessionId': '435d78',
      'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'location': location,
      'message': message,
      'data': data,
      'hypothesisId': hypothesisId,
    };
    final line = '${jsonEncode(payload)}\n';
    File('debug-435d78.log').writeAsStringSync(line, mode: FileMode.append);
  } catch (_) {}
}
