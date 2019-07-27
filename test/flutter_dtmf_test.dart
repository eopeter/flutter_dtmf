import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dtmf/flutter_dtmf.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_dtmf');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterDtmf.platformVersion, '42');
  });
}
