package com.eopeter.flutter_dtmf

import android.content.Context
import android.media.ToneGenerator
import android.media.AudioManager
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class DtmfPlugin : FlutterPlugin, MethodCallHandler {

    // Instance properties for channel, context, and audio manager
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private lateinit var audioManager: AudioManager

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Initialize the MethodChannel using the new v2 binding
        channel = MethodChannel(binding.binaryMessenger, "flutter_dtmf")
        channel.setMethodCallHandler(this)
        applicationContext = binding.applicationContext
        audioManager = applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *>
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "playTone" -> {
                val digits = arguments?.get("digits") as? String
                val durationMs = arguments?.get("durationMs") as? Int
                val volume = arguments?.get("volume") as? Double ?: 0.5
                val ignoreDtmfSystemSettings = arguments?.get("ignoreDtmfSystemSettings") as? Boolean ?: false
                val forceMaxVolume = arguments?.get("forceMaxVolume") as? Boolean ?: false
                if (digits != null && durationMs != null) {
                    playTone(
                        digits.trim(),
                        durationMs,
                        volume,
                        ignoreDtmfSystemSettings,
                        forceMaxVolume
                    )
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENTS", "Missing required arguments for playTone", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun playTone(
        digits: String,
        durationMs: Int,
        volume: Double,
        ignoreDtmfSystemSettings: Boolean,
        forceMaxVolume: Boolean
    ) {
        if (!ignoreDtmfSystemSettings) {
            var isDtmfToneDisabled = false
            try {
                isDtmfToneDisabled = Settings.System.getInt(
                    applicationContext.contentResolver,
                    Settings.System.DTMF_TONE_WHEN_DIALING, 1
                ) == 0
            } catch (e: Settings.SettingNotFoundException) {
                Log.e("DTMFPlugin", e.toString())
            }
            if (isDtmfToneDisabled) {
                Log.i("DTMFPlugin", "No sound is played: DTMF Tone is disabled on device and not ignored.")
                return
            }
        }

        val streamType = AudioManager.STREAM_DTMF
        var maxVolume = audioManager.getStreamMaxVolume(streamType)
        if (forceMaxVolume) {
            maxVolume = 100
        }
        // Set the volume level as a percentage of the maximum
        val targetVolume = (volume * maxVolume).toInt()
        audioManager.setStreamVolume(streamType, targetVolume, 0)
        val toneGenerator = ToneGenerator(streamType, targetVolume)

        Thread {
            for (digit in digits) {
                val toneType = getToneType(digit.toString())
                if (toneType != -1) {
                    toneGenerator.startTone(toneType, durationMs)
                }
                Thread.sleep((durationMs + 80).toLong())
            }
            toneGenerator.release() // Release to allow high-frequency playback
        }.start()
    }

    private fun getToneType(digit: String): Int {
        return when (digit) {
            "0" -> ToneGenerator.TONE_DTMF_0
            "1" -> ToneGenerator.TONE_DTMF_1
            "2" -> ToneGenerator.TONE_DTMF_2
            "3" -> ToneGenerator.TONE_DTMF_3
            "4" -> ToneGenerator.TONE_DTMF_4
            "5" -> ToneGenerator.TONE_DTMF_5
            "6" -> ToneGenerator.TONE_DTMF_6
            "7" -> ToneGenerator.TONE_DTMF_7
            "8" -> ToneGenerator.TONE_DTMF_8
            "9" -> ToneGenerator.TONE_DTMF_9
            "*" -> ToneGenerator.TONE_DTMF_S
            "#" -> ToneGenerator.TONE_DTMF_P
            "A" -> ToneGenerator.TONE_DTMF_A
            "B" -> ToneGenerator.TONE_DTMF_B
            "C" -> ToneGenerator.TONE_DTMF_C
            "D" -> ToneGenerator.TONE_DTMF_D
            else -> -1
        }
    }
}
