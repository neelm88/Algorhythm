//
//  ViewController.swift
//  SoundTranscription
//
//  Created by CatalinA on 4/6/21.
//

import SwiftUI
import AVFoundation
import aubio
import Combine

struct TunerView: View {
    

    
    @StateObject var curNote = Tuner()
    
    private var bufferSize = UInt32(2048);
    
    
    var body : some View{
        VStack{
            Text(curNote.curNote)
        }
    }
    
    
}

class Tuner: NSObject, ObservableObject{
    
    private var audioEngine: AVAudioEngine!
    private var mic: AVAudioInputNode!
    
    @Published var curNote: String = ""
    
    private var bufferSize = UInt32(2048);
    
    override init() {
        super.init()
        configureAudioSession()
        audioEngine = AVAudioEngine()
        mic = audioEngine.inputNode

        startRecording()

        self.curNote = ""
    }
    
        
    func setText(textVal:String) {
        self.curNote = textVal
    }

    func startRecording() {
        let micFormat = mic.inputFormat(forBus: 0)
        
        setText(textVal:"Ilabel2!")
        
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        var midiDict = [String](repeating:"", count: 127)
        
        var noteIndex = 0
        for i in 0...126 {
            if noteIndex > 11 {
              noteIndex = 0
            }
            midiDict[i] = noteNames[noteIndex]
            noteIndex += 1
        }
        
        let man = new_aubio_notes("default", 2048, 512, 44100)
        //aubio_notes_set_silence(man, 5)
        mic.installTap(onBus: 0, bufferSize: bufferSize, format: micFormat) { (buffer, when) in
            let sampleData = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
            let samples = new_fvec(buffer.frameLength)
            
            for i in 0...sampleData.count-1 {
                fvec_set_sample(samples, sampleData[i], UInt32(i))
            }
            
            let output = new_fvec(3)
            
            aubio_notes_do(man, samples, output)
    
            let mnote = fvec_get_sample(output, 0) - 1
        
            if mnote >= 0 {
                DispatchQueue.main.async{ [unowned self] in
                    self.setText(textVal: midiDict[Int(mnote) + 2])
                }
            }
        }
  
        startEngine()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [.mixWithOthers, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
    }

    private func startEngine() {
        guard !audioEngine.isRunning else {
            return
        }

        do {
            try audioEngine.start()
        }
        catch {
            print("Error starting audio engine!")
        }
    }
}


