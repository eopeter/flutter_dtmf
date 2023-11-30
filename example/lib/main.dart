import 'package:flutter/material.dart';
import 'package:flutter_dtmf/dtmf.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: ElevatedButton(
          child: Text("Play DTMF"),
          onPressed: () async {
            await Dtmf.playTone(
                digits: "#1234567890*",
                samplingRate: 8000,
                durationMs: 160,
                volume: 0.8);
          },
        )),
      ),
    );
  }
}
