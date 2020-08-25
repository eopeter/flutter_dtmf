import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterDtmf {
  static const MethodChannel _channel = const MethodChannel('flutter_dtmf');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> playTone(
      {@required String digits,
      double samplingRate,
      int durationMs = 500}) async {
    assert(digits != null);
    final Map<String, Object> args = <String, dynamic>{
      "digits": digits,
      "samplingRate": samplingRate,
      "durationMs": durationMs
    };
    await _channel.invokeMethod('playTone', args);
  }
}
