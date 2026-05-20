import 'package:flutter/services.dart';

class ExportActions {
  const ExportActions();

  static const _channel = MethodChannel('com.langgeng.clip/export_actions');

  Future<void> share({required String uri, required String title}) {
    return _channel.invokeMethod<void>('share', {'uri': uri, 'title': title});
  }
}

class ExportActionException implements Exception {
  const ExportActionException(this.message);

  final String message;

  @override
  String toString() => message;
}
