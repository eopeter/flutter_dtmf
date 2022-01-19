import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class DtmfPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
        'plugins.flutter.io/url_launcher',
        const StandardMethodCodec());
    final DtmfPlugin instance = DtmfPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'playTone':
        final String digits = call.arguments['digits'];
        final int? durationMs = call.arguments['durationMs'];
        return _playTone(digits, durationMs);
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The flutter dtmf plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }

  bool _playTone(String digits, int? durationMs) {
    var dtmf = DTMF();
    dtmf.playTone(digits, durationMs);
    return true;
  }

}


class DTMF {

  var allFrequencies = {
    "1": [697, 1209],
    "2": [697, 1336],
    "3": [697, 1477],
    "A": [697, 1633],
    "4": [770, 1209],
    "5": [770, 1336],
    "6": [770, 1477],
    "B": [770, 1633],
    "7": [852, 1209],
    "8": [852, 1336],
    "9": [852, 1477],
    "C": [852, 1633],
    "*": [941, 1209],
    "0": [941, 1336],
    "#": [941, 1477],
    "D": [941, 1633],
  };


  void playTone(String digits, int? durationMs) {
    dynamic audioContext = js.context.callMethod('AudioContext',
        ['new (window.AudioContext || window.webkitAudioContext)()']);

    for (var i in digits.split('')) {
      var tone = Tone(
          context: audioContext,
          frequency1: allFrequencies[i]![0],
          frequency2: allFrequencies[i]![1]);
      if (tone.status == 0) {
        tone.start();
        tone.stop();
      }
    }
  }
}

class Tone {
  dynamic context;
  int? frequency1;
  int? frequency2;
  int status = 0;
  dynamic _osc1;
  dynamic _osc2;
  dynamic _gainNode;
  dynamic _filter;

  Tone({this.context, this.frequency1, this.frequency2}) {
    _osc1 = context.createOscillator();
    _osc2 = context.createOscillator();
    _osc1.frequency.value = this.frequency1;
    _osc2.frequency.value = this.frequency2;

    _gainNode = context.createGain();
    _gainNode.gain.value = 0.25;

    _filter = context.createBiquadFilter();
    _filter.type = "lowpass";
    _filter.frequency = 8000;

    _osc1.connect(_gainNode);
    _osc2.connect(_gainNode);

    _gainNode.connect(_filter);
    _filter.connect(context.destination);
  }

  void start() {
    _osc1.start(0);
    _osc2.start(0);
    this.status = 1;
  }

  void stop() {
    _osc1.stop(0);
    _osc2.stop(0);
    this.status = 0;
  }
}
/*
class DTMF{
  var allFrequencies = {
    "1": [697, 1209],
    "2": [697, 1336],
    "3": [697, 1477],
    "A": [697, 1633],
    "4": [770, 1209],
    "5": [770, 1336],
    "6": [770, 1477],
    "B": [770, 1633],
    "7": [852, 1209],
    "8": [852, 1336],
    "9": [852, 1477],
    "C": [852, 1633],
    "*": [941, 1209],
    "0": [941, 1336],
    "#": [941, 1477],
    "D": [941, 1633],
  };


  void playTone(String digits) {
    var audioContext = AudioContext();
    for (var i in digits.split('')) {
      var tone = Tone(
          context: audioContext,
          frequency1: allFrequencies[i][0],
          frequency2: allFrequencies[i][1]);
      if (tone.status == 0) {
        tone.start();
        tone.stop();
      }
    }
  }
}

class Tone {
  AudioContext context;
  int frequency1;
  int frequency2;
  int status = 0;
  OscillatorNode _osc1;
  OscillatorNode _osc2;
  GainNode _gainNode;
  BiquadFilterNode _filter;

  Tone({this.context, this.frequency1, this.frequency2}) {
    _osc1 = context.createOscillator();
    _osc2 = context.createOscillator();
    _osc1.frequency.value = this.frequency1;
    _osc2.frequency.value = this.frequency2;

    _gainNode = context.createGain();
    _gainNode.gain.value = 0.25;

    _filter = context.createBiquadFilter();
    _filter.type = "lowpass";
    _filter.frequency.value = 8000;

    _osc1.connectNode(_gainNode);
    _osc2.connectNode(_gainNode);

    _gainNode.connectNode(_filter);
    _filter.connectNode(context.destination);
  }

  void start() {
    _osc1.start2(0);
    _osc2.start2(0);
    this.status = 1;
  }

  void stop() {
    _osc1.stop(0);
    _osc2.stop(0);
    this.status = 0;
  }
}

 */

