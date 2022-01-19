import 'package:flutter/services.dart';
import 'package:flutter_dtmf/dtmf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_dtmf');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('playTone', () async {
    expect(await Dtmf.playTone(digits: "0123456789"), true);
  });
}
