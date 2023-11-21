import 'package:flutter_dtmf/models/tone.dart';
import 'dart:js' as js;

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

  /// Plays the DTMF Tones Associated with the [digits]. Each tone is played for the duration [durationMs] in milliseconds
  /// Returns true if tone played successfully
  ///
  Future<bool> playTone(
      {required String digits,
      int? durationMs,
      double? samplingRate,
      double? volume}) {
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
        return Future.value(true);
      }
    }

    return Future.value(false);
  }
}
