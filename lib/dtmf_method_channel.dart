import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dtmf/dtmf_platform_interface.dart';

class MethodChannelDtmf extends DtmfPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_dtmf');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> playTone(
      {required String digits,
      int? durationMs,
      double? samplingRate,
      double? volume,
        bool?  ignoreDtmfSettings}) async {
    final Map<String, Object?> args = <String, dynamic>{
      "digits": digits,
      "samplingRate": samplingRate,
      "durationMs": durationMs,
      "volume": volume,
      "ignoreDtmfSettings":ignoreDtmfSettings
    };
    return await methodChannel.invokeMethod('playTone', args);
  }
}
