import 'package:flutter/services.dart';

/// Calls into MainActivity.kt / LogWidgetProvider.kt over the app's single
/// method channel. Small and dependency-free on purpose.
class NativeBridge {
  NativeBridge._();
  static const _channel = MethodChannel('afterglow/window');

  /// Fires when the widget's "Log event" button is tapped while the app is
  /// already running.
  static void onLaunchAction(void Function(String action) handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'launchAction') handler(call.arguments as String);
    });
  }

  /// The action the app was cold-started with (e.g. "log"), consumed once.
  static Future<String?> takeLaunchAction() =>
      _channel.invokeMethod<String>('takeLaunchAction');

  /// Android "Save to…" picker. Returns false if the user cancelled.
  static Future<bool> saveDocument(
      {required String name, required String mime, required Uint8List bytes}) async {
    return await _channel.invokeMethod<bool>(
            'saveDocument', {'name': name, 'mime': mime, 'bytes': bytes}) ??
        false;
  }

  static Future<void> updateWidget({
    DateTime? episodeStart,
    int? expectedDays,
    required bool hideStatus,
  }) =>
      _channel.invokeMethod('updateWidget', {
        'episodeStart': episodeStart?.millisecondsSinceEpoch ?? -1,
        'expectedDays': expectedDays ?? 0,
        'hideStatus': hideStatus,
      });
}
