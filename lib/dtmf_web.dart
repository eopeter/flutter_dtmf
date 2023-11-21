import 'dart:async';
import 'dart:html' as html show window;

import 'package:flutter_dtmf/dtmf_platform_interface.dart';
import 'package:flutter_dtmf/models/dtmf.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// DtmfPlugin is the main plugin class
class DtmfPlugin extends DtmfPlatform {
  /// Constructs a DtmfPlugin
  DtmfPlugin();

  static void registerWith(Registrar registrar) {
    DtmfPlatform.instance = DtmfPlugin();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }

  @override
  Future<bool> playTone(
      {required String digits,
      int? durationMs,
      double? samplingRate,
      double? volume}) async {
    var dtmf = DTMF();
    return await dtmf.playTone(
        digits: digits,
        durationMs: durationMs,
        samplingRate: samplingRate,
        volume: volume);
  }
}
