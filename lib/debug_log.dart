import 'debug_log_stub.dart' if (dart.library.io) 'debug_log_io.dart' as impl;

void writeDebugLog(String location, String message, Map<String, dynamic> data, String hypothesisId) {
  impl.writeDebugLog(location, message, data, hypothesisId);
}
