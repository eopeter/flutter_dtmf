import Flutter
import UIKit
import AVFoundation
import CallKit

public class SwiftFlutterDtmfPlugin: NSObject, FlutterPlugin {

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
    let channel = FlutterMethodChannel(name: "flutter_dtmf", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterDtmfPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        if call.method == "playTone"
        {
            guard let digits = arguments?["digits"] as? String else {return}
            let samplingRate =  arguments?["samplingRate"] as? Double ?? 8000.0
            playTone(digits: digits, samplingRate: samplingRate)
        }

    }
    
    func playTone(digits: String, samplingRate: Double)
    {
       
        let _sampleRate = Float(samplingRate)

        if let tones = DTMF.tonesForString(digits) {
            let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: Double(_sampleRate), channels: 2, interleaved: false)!
            
            // fill up the buffer with some samples
            var allSamples = [Float]()
            for tone in tones {
                let samples = DTMF.generateDTMF(tone, markSpace: DTMF.motorola, sampleRate: _sampleRate)
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
                print("Engine start failed - \(error)")
            }
            
            _player.scheduleBuffer(buffer, at:nil,completionHandler:nil)
            _player.play()

    }
  }
  
}
