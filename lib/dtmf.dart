import 'dart:async';
import 'package:flutter/services.dart';

/// Dtmf enables playing DTMF tones crossplatform
class Dtmf {
  static const MethodChannel _channel = const MethodChannel('flutter_dtmf');

  /// Plays the DTMF Tones Associated with the [digits]. Each tone is played for the duration [durationMs] in milliseconds
  /// at the specified volume. If no volume is specified, the system default is used. Volume value should be between
  /// 0 and 1.
  /// Returns true if tone played successfully
  /// Set ignoreDtmfSystemSettings to true, if you want to play sound even when dtmf sounds are disable on the device (ex : on a tablet)
  /// Set forceMaxVolume to true if you want to increase max volume to the max volume of the phone, (and not just max volume of DTMF sounds).
  /// If you force max Volume to true, you can still control the volume with the volume atribute.
  ///
  static Future<bool?> playTone(
      {required String digits,
      int durationMs =160,
      double samplingRate =500,
      double volume = 1,
      bool ignoreDtmfSystemSettings=false,
      bool forceMaxVolume=false}) async {

    final Map<String, Object?> args = <String, dynamic>{
      "digits": digits,
      "samplingRate": samplingRate,
      "durationMs": durationMs,
      "volume": volume,
      "ignoreDtmfSystemSettings":ignoreDtmfSystemSettings,
      "forceMaxVolume":forceMaxVolume};
    return await _channel.invokeMethod('playTone', args);
  }
}
