# flutter_dtmf

Generates DTFM Tones for Flutter Application. This can be used in VOIP applications or other applications that need to generate DTMF Tones.

## Usage

```

await Dtmf.playTone(digits: "1234567890ABCD*#", durationMs: 500, volume: 0.8);
await Dtmf.playTone(digits: "1", samplingRate: 80000.0);

```

## To Do
[DONE] Android Implementation using ToneGenerator class
* Adjusting the Mark and Space in addition to Sampling Rate for a different output
