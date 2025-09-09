import Flutter
import UIKit
import AVFoundation
import CallKit

public class SwiftDtmfPlugin: NSObject, FlutterPlugin {

    var _engine: AVAudioEngine
    var _player:AVAudioPlayerNode
    var _mixer: AVAudioMixerNode
    
  public override init() {
    _engine = AVAudioEngine();
    _player = AVAudioPlayerNode()
    _mixer = _engine.mainMixerNode;
    
    super.init()
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    do {
      try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch let error as NSError {
        print("AVAudioSession setCategory failed - \(error)")
    }
    let channel = FlutterMethodChannel(name: "flutter_dtmf", binaryMessenger: registrar.messenger())
    let instance = SwiftDtmfPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        if call.method == "playTone"
        {
            guard let digits = arguments?["digits"] as? String else {return}
            let samplingRate =  arguments?["samplingRate"] as? Double ?? 8000.0
            let durationMs =  arguments?["durationMs"] as? Int ?? 500
            let volume =  arguments?["volume"] as? Double
            playTone(digits: digits, volume: volume, samplingRate: samplingRate, durationMs: durationMs, flutterResult: result)
        }

    }
    
    func playTone(digits: String, volume: Double?, samplingRate: Double, durationMs: Int, flutterResult: @escaping FlutterResult)
    {
       
        let _sampleRate = Float(samplingRate)

        if let tones = DTMF.tonesForString(digits) {
            let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: Double(_sampleRate), channels: 2, interleaved: false)!
            
            // fill up the buffer with some samples
            var allSamples = [Float]()
            for tone in tones {
                let samples = DTMF.generateDTMF(tone, markSpace: MarkSpaceType(Float(durationMs), Float(durationMs)), sampleRate: _sampleRate)
                allSamples.append(contentsOf: samples)
            }
            
            let frameCount = AVAudioFrameCount(allSamples.count)
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount)!
            
            buffer.frameLength = frameCount
            let channelMemory = buffer.floatChannelData!
            for channelIndex in 0 ..< Int(audioFormat.channelCount) {
                let frameMemory = channelMemory[channelIndex]
                memcpy(frameMemory, allSamples, Int(frameCount) * MemoryLayout<Float>.size)
            }
            
            _engine.attach(_player)
            _engine.connect(_player, to:_mixer, format:audioFormat)
            
            do {
                try _engine.start()
            } catch let error as NSError {
                flutterResult(false)
                print("Engine start failed - \(error)")
            }
            
            _player.scheduleBuffer(buffer, at:nil,completionHandler:nil)
            if (volume != nil) {
                _player.volume = Float(volume!)
            }
            _player.play()
            flutterResult(true)
    }
  }
  
}
