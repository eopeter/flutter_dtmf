// Tone plays a DTMF Tone given a frequency
class Tone {
  dynamic context;
  int? frequency1;
  int? frequency2;
  int status = 0;
  dynamic _osc1;
  dynamic _osc2;
  dynamic _gainNode;
  dynamic _filter;

  /// constructor
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

  /// start plays the tone
  void start() {
    _osc1.start(0);
    _osc2.start(0);
    this.status = 1;
  }

  /// stop terminates playing the tone
  void stop() {
    _osc1.stop(0);
    _osc2.stop(0);
    this.status = 0;
  }
}
