import Flutter
import UIKit
import AVFoundation
import CallKit

public class SwiftDtmfPlugin: NSObject, FlutterPlugin, AVAudioPlayerDelegate {
    
    private var _player: AVAudioPlayer?
    private var _session = AVAudioSession.sharedInstance()
    private var _playing = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
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
    
    private func uint16le(_ v: UInt16) -> Data {
        var x = v.littleEndian
        return Data(bytes: &x, count: MemoryLayout<UInt16>.size)
    }
    private func uint32le(_ v: UInt32) -> Data {
        var x = v.littleEndian
        return Data(bytes: &x, count: MemoryLayout<UInt32>.size)
    }
    
    func makeDtmfData(digits: String, samplingRate: Double, durationMs: Int) -> Data? {
        
        guard let tones = DTMF.tonesForString(digits) else {return nil}
        
        var pcm16 = [Int16]()
        
        for tone in tones {
            let samples = DTMF.generateDTMF(tone, markSpace: MarkSpaceType(Float(durationMs), Float(durationMs)), sampleRate: Float(samplingRate))
            for sample in samples {
                let v = max(-1.0, min(1.0, sample))
                pcm16.append(Int16(v * Float(Int16.max)))
            }
        }
        
        let numChannels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let byteRate = UInt32(samplingRate) * UInt32(numChannels) * UInt32(bitsPerSample / 8)
        let blockAlign = UInt16(numChannels) * (bitsPerSample / 8)
        let dataSize = UInt32(pcm16.count * MemoryLayout<Int16>.size)

        var data = Data()
        
        
        // RIFF header
        data.append("RIFF".data(using: .ascii)!)
        data.append(uint32le(36 + dataSize))
        data.append("WAVE".data(using: .ascii)!)

        // fmt chunk
        data.append("fmt ".data(using: .ascii)!)
        data.append(uint32le(16)) // PCM fmt chunk size
        data.append(uint16le(1))  // audio format 1=PCM
        data.append(uint16le(numChannels))
        data.append(uint32le(UInt32(samplingRate)))
        data.append(uint32le(byteRate))
        data.append(uint16le(blockAlign))
        data.append(uint16le(bitsPerSample))

        // data chunk
        data.append("data".data(using: .ascii)!)
        data.append(uint32le(dataSize))
        
        // PCM payload
        pcm16.withUnsafeBufferPointer { bp in
            data.append(Data(buffer: bp))
        }
        
        return data
    }
    
    func playTone(digits: String, volume: Double?, samplingRate: Double, durationMs: Int, flutterResult: @escaping FlutterResult)
    {
        
        do {
            try _session.setCategory(.playback, options: [.mixWithOthers])
            if !_session.isOtherAudioPlaying {
                try _session.setActive(true)
            }
        } catch {
            print("AudioSession setCategory/setActive failed: \(error)")
        }

        guard let wavData = makeDtmfData(digits: digits, samplingRate: samplingRate, durationMs: durationMs) else {
            flutterResult(false)
            return
        }
        
        do{
            let p = try AVAudioPlayer(data: wavData)
            p.volume = Float(volume ?? 1.0)
            p.delegate = self
            p.prepareToPlay()
            DispatchQueue.main.async{
                self._player?.stop()
                self._player = p
                self._playing = p.play()
                flutterResult(self._playing)
            }
        }catch{
            print("AVAudioPlayer init failed: \(error)")
            flutterResult(false)
        }
        
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        _playing = false
        
        do{
            try _session.setCategory(.ambient, mode: .default, options: [])
            try _session.setActive(false, options: [.notifyOthersOnDeactivation])
        }catch{
            print("AudioSession setCategory/setActive failed: \(error)")
        }
    }
}
