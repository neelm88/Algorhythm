//
//  AudioRecorder.swift
//  Algorhythm
//
//  Created by Dan Bellini on 3/16/21.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    
    var audioRecorder: AVAudioRecorder!
    
    var recordings = [Recording]()
    
    var recording = false{
        didSet{
            objectWillChange.send(self)
        }
    }
    
    var songName : String
    
    init(songName : String){
        self.songName = songName
        super.init()
        fetchRecordings()
    }
    
    
    func startRecording(){
        
        let recordingSession = AVAudioSession.sharedInstance()
        do{
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
        } catch {
            print("Failed to set up recording session")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = documentPath.appendingPathComponent("\(self.songName)_\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).wav")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do{
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.record()
            
            recording = true
        } catch {
            print("Could not start recording audio")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        recording = false
        
        fetchRecordings()
    }
    
    func fetchRecordings() {
            recordings.removeAll()
            
            let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            for audio in directoryContents {
                if audio.absoluteString.contains(self.songName){
                    print("here")
                    let recording = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
                    recordings.append(recording)
                }
            }
        
        recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
                
        objectWillChange.send(self)
    }
    
    func deleteRecording(urlsToDelete: [URL]) {
            
            for url in urlsToDelete {
                print(url)
                do {
                   try FileManager.default.removeItem(at: url)
                } catch {
                    print("File could not be deleted!")
                }
            }
        
            fetchRecordings()
        
//        for x in 0...recordings.count - 1{
//            if urlsToDelete.contains(recordings[x].fileURL) {
//                print("here1")
//                recordings.remove(at: x)
//                objectWillChange.send(self)
//                break
//            }
//        }
            
        
            
        }
    
    func getCreationDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}
