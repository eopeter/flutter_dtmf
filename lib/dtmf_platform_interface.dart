import 'package:flutter_dtmf/dtmf_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class DtmfPlatform extends PlatformInterface {
  DtmfPlatform() : super(token: _token);

  static final Object _token = Object();

  static DtmfPlatform _instance = MethodChannelDtmf();

  /// The default instance of [DtmfPlatform] to use.
  ///
  /// Defaults to [MethodChannelDtmf].
  static DtmfPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DtmfPlatform] when
  /// they register themselves.
  static set instance(DtmfPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> playTone(
      {required String digits,
      int? durationMs,
      double? samplingRate,
      double? volume,
      bool? ignoreDtmfSettings}) {
    throw UnimplementedError('playTone() has not been implemented.');
  }
}
