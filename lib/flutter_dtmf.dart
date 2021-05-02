import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterDtmf {
  static const MethodChannel _channel = const MethodChannel('flutter_dtmf');

  /// Plays the DTMF Tones Associated with the [digits]. Each tone is played for the duration [durationMs] in milliseconds
  /// Returns true if tone played successfully
  ///
  static Future<bool?> playTone(
      {required String digits,
      double? samplingRate,
      int durationMs = 500}) async {
    final Map<String, Object?> args = <String, dynamic>{
      "digits": digits,
      "samplingRate": samplingRate,
      "durationMs": durationMs
    };
    return await _channel.invokeMethod('playTone', args);
  }
}
