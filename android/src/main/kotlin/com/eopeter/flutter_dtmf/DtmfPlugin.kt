package com.eopeter.flutter_dtmf
import android.content.Context
import android.media.ToneGenerator
import android.media.AudioManager
import android.provider.Settings
import android.util.Log
import androidx.core.content.ContextCompat.getSystemService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class DtmfPlugin : FlutterPlugin, MethodCallHandler {

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        setUpChannels(binding.binaryMessenger)
        applicationContext = binding.applicationContext
        audioManager = applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }

    companion object {
        var channel: MethodChannel? = null
        private lateinit var applicationContext: Context
        private lateinit var audioManager: AudioManager

        fun setUpChannels(messenger: BinaryMessenger) {
            channel = MethodChannel(messenger, "flutter_dtmf")
            channel?.setMethodCallHandler(DtmfPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *>

        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "playTone") {
            val digits = arguments?.get("digits") as? String
            val samplingRate = arguments?.get("samplingRate") as? Float
            val durationMs = arguments?.get("durationMs") as? Int
            val volume = arguments?.get("volume") as Double
            val ignoreDtmfSystemSettings = arguments?.get("ignoreDtmfSystemSettings") as Boolean
            val forceMaxVolume = arguments?.get("forceMaxVolume") as Boolean
            if (digits != null) {
                playTone(
                    digits.trim(),
                    durationMs as Int,
                    volume,
                    ignoreDtmfSystemSettings,
                    forceMaxVolume
                )
                result.success(true)
            }
        } else {
            result.notImplemented()
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
                ) == 0;
            } catch (e: Settings.SettingNotFoundException) {
                Log.e("DTMFPlugin", e.toString())
            }
            if (isDtmfToneDisabled) {
                Log.i(
                    "DTMFPlugin",
                    "No sound is played : Dtmf Tone is disabled on device and not ignored."
                )
                return;
            }
        }

        val streamType = AudioManager.STREAM_DTMF

        var maxVolume = audioManager.getStreamMaxVolume(streamType)
        if (forceMaxVolume) {
            maxVolume = 100
        }
        // Set the volume level as a percentage
        var targetVolume = volume * maxVolume
        audioManager.setStreamVolume(streamType, targetVolume.toInt(), 0)
        // Adjust volume using AudioManager
        var toneGenerator = ToneGenerator(streamType, targetVolume.toInt())


        Thread(object : Runnable {
            override fun run() {
                for (i in digits.indices) {
                    val toneType = getToneType(digits[i].toString())
                    if (toneType != -1)
                        toneGenerator?.startTone(toneType, durationMs)
                    Thread.sleep((durationMs + 80).toLong())
                }
                toneGenerator.release(); //Is needed to be able to play at high frequency !
            }
        }).start()
    }

    private fun getToneType(digit: String): Int {
        when (digit) {
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
