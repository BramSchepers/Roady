// #region agent log
// Instrumentation: logs from app (emulator) to host ingest + local file on device.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _host = 'http://10.0.2.2:7242/ingest/c9985c0c-9b3b-4bbf-ae86-f4d9925670ee';

Future<void> _writeToDeviceFile(String line) async {
  try {
    final dir = Directory.systemTemp;
    final f = File('${dir.path}/roady_debug.log');
    await f.writeAsString('$line\n', mode: FileMode.append);
  } catch (_) {}
}

Future<void> debugLog(String location, String message, String hypothesisId,
    [Map<String, dynamic>? data]) async {
  final payload = {
    'location': location,
    'message': message,
    'hypothesisId': hypothesisId,
    'data': data ?? {},
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'sessionId': 'debug-session',
  };
  final line = jsonEncode(payload);
  unawaited(_writeToDeviceFile(line));
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse(_host));
    request.headers.set('Content-Type', 'application/json');
    request.write(line);
    await request.close();
    client.close();
  } catch (_) {}
}

void debugLogFire(String location, String message, String hypothesisId,
    [Map<String, dynamic>? data]) {
  print('[DEBUG $hypothesisId] $location: $message');
  unawaited(debugLog(location, message, hypothesisId, data));
}
// #endregion
