package com.dormmom.flutter_dtmf

import android.media.ToneGenerator
import android.media.AudioManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


class FlutterDtmfPlugin: FlutterPlugin, MethodCallHandler {
  
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    setUpChannels(binding.binaryMessenger)
  }
  
  companion object {

    var channel: MethodChannel? = null
    
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      setUpChannels(registrar.messenger())
    }
    
    fun setUpChannels(messenger: BinaryMessenger){
      channel = MethodChannel(messenger, "flutter_dtmf")
      channel?.setMethodCallHandler(FlutterDtmfPlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    val arguments = call.arguments as? Map<*, *>

    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }
    else if (call.method == "playTone")
    {
      val digits = arguments?.get("digits") as? String;
      val samplingRate = arguments?.get("samplingRate") as? Float;
      val durationMs = arguments?.get("durationMs") as? Int;

      if (digits != null) {
        playTone(digits, durationMs as Int)
        result.success(true)
      }
    }
    else {
      result.notImplemented()
    }
  }

  private fun playTone(digits: String, durationMs: Int) {
    val streamType = AudioManager.STREAM_DTMF
    val volume = 80
    val toneGenerator = ToneGenerator(streamType, volume)
    Thread(object : Runnable {
      override fun run() {
        for (i in digits.indices)
        {
          val toneType = getToneType(digits[i].toString())
          toneGenerator.startTone(toneType, durationMs)
          Thread.sleep((durationMs + 80).toLong())
        }
      }
    }).start()
  }

  private fun getToneType(digit: String): Int {
    when(digit) {
      "0" -> return ToneGenerator.TONE_DTMF_0
      "1" -> return ToneGenerator.TONE_DTMF_1
      "2" -> return ToneGenerator.TONE_DTMF_2
      "3" -> return ToneGenerator.TONE_DTMF_3
      "4" -> return ToneGenerator.TONE_DTMF_4
      "5" -> return ToneGenerator.TONE_DTMF_5
      "6" -> return ToneGenerator.TONE_DTMF_6
      "7" -> return ToneGenerator.TONE_DTMF_7
      "8" -> return ToneGenerator.TONE_DTMF_8
      "9" -> return ToneGenerator.TONE_DTMF_9
      "*" -> return ToneGenerator.TONE_DTMF_S
      "#" -> return ToneGenerator.TONE_DTMF_P
      "A" -> return ToneGenerator.TONE_DTMF_A
      "B" -> return ToneGenerator.TONE_DTMF_B
      "C" -> return ToneGenerator.TONE_DTMF_C
      "D" -> return ToneGenerator.TONE_DTMF_D
    }

    return -1
  }
  
  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    channel = null
  }


}
