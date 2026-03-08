import 'dart:convert';

void writeDebugLog(String location, String message, Map<String, dynamic> data, String hypothesisId) {
  final payload = {
    'sessionId': '435d78',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'location': location,
    'message': message,
    'data': data,
    'hypothesisId': hypothesisId,
  };
  print('DEBUG_435d78 ${jsonEncode(payload)}');
}
