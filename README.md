# flutter_dtmf

Generates DTFM Tones for Flutter Application. You can change the Sampling Rate to get a different output.

## Usage

```

await FlutterDtmf.playTone(digits: "1234567890ABCD*#");
await FlutterDtmf.playTone(digits: "1", samplingRate: 80000.0);

```

## To Do
* Android Implementation using ToneGenerator class
* Adjusting the Mark and Space in addition to Sampling Rate for a different output
