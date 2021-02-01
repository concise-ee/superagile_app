import 'package:cloud_functions/cloud_functions.dart';
import 'package:logging/logging.dart';

FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

final HttpsCallable _logCallable = _functions.httpsCallable('logInfo');
final HttpsCallable _errorCallable = _functions.httpsCallable('logError');

void _logToCloud(LogRecord record) async {
  if (record.level == Level.INFO) _logCallable.call({'message': _buildMessage(record)});
  if (record.level == Level.SEVERE) _errorCallable.call({'message': _buildMessage(record)});
}

void initLogger() {
  Logger.root.onRecord.listen((LogRecord record) {
    print(_buildMessage(record));
    _logToCloud(record);
  });
}

String _buildMessage(LogRecord record) =>
    '${record.loggerName} ${record.level.name}: ${record.time}: ${record.message}';
