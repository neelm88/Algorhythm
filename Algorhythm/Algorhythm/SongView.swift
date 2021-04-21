//
//  SongView.swift
//  Algorhythm
//
//  Created by Dan Bellini on 2/9/21.
//

import Foundation
import SwiftUI
import SwiftSocket

struct SongView : View {
    
    @State var song : SongInfo
    @State var imageViews : [ImageView] = []
    @State var isOnAppear = false
    @State private var showingSheet = false
    
    @EnvironmentObject var addedSong : AddedSong
    
    @ObservedObject var audioRecorder: AudioRecorder
    
    @State var client = TCPClient(address: "127.0.0.1", port: 2020)
    
    
    
    
    var body: some View{
        ScrollView(.vertical){
                VStack(alignment: .leading){
                    HStack{
                        VStack(alignment: .leading){
                        Text(song.name)
                            .font(.title)
                            .padding(.leading, 10)
                        Text(song.artist)
                            .font(.subheadline)
                            .padding(.leading, 10)
                        }
                        Spacer()
                        Button("Show Recordings") {
                            showingSheet.toggle()
                        }.sheet(isPresented: $showingSheet) {
                                    RecordingsView(audioRecorder: audioRecorder, client: client)
                        }
                    }
                    if isOnAppear{
                        PageView(pages: imageViews)
                            .aspectRatio(contentMode: .fit)
                    }
                }
                
                
            }.onAppear(perform: {
                for data in self.song.photo{
                    imageViews.append(ImageView(image:  UIImage(data: data)!))
                }
                self.isOnAppear = true
                switch client.connect(timeout: 10) {
                   case .success:
                     print("yay")
                   case .failure(let error):
                     print("💩")
                 }
            })
            Spacer()
            VStack{
                if audioRecorder.recording == false {
                    Button(action: {audioRecorder.startRecording()}, label: {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40)
                    })
                }else{
                    Button(action: {stopRecording()}, label: {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40)
                    })
                }
            }
        }
    
    func stopRecording(){
        let fileManager = FileManager.default
        audioRecorder.stopRecording()
        
                
        
        
    }
        
    }


struct RecordingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioRecorder : AudioRecorder
    var client : TCPClient
    var body: some View {
        List {
            ForEach(audioRecorder.recordings, id: \.createdAt) { recording in
                RecordingRow(audioURL: recording.fileURL, client: client)
            }
            .onDelete(perform: delete)
        }
    }
    
    func delete(at offsets: IndexSet) {
            var urlsToDelete = [URL]()
            for index in offsets {
                urlsToDelete.append(audioRecorder.recordings[index].fileURL)
            }
            audioRecorder.deleteRecording(urlsToDelete: urlsToDelete)
            
            //audioRecorder.fetchRecordings()
        }
}

struct RecordingRow: View {
    
    var audioURL: URL
    var client : TCPClient
    @ObservedObject var audioPlayer = AudioPlayer()
    @State var sent = false
    @State var acc : Float = 0.0
    
    var body: some View {
        HStack {
            Text("\(audioURL.lastPathComponent)")
            Spacer()
            if !sent{
                Button("Send", action: sendMusic)
            }else{
                Text("\(self.acc.truncate(places: 2))%")
            }
            
            if audioPlayer.isPlaying == false {
                Button(action: {
                    self.audioPlayer.startPlayback(audio: self.audioURL)
                }) {
                    Image(systemName: "play.circle")
                        .imageScale(.large)
                }
            } else {
                Button(action: {
                    self.audioPlayer.stopPlayback()
                }) {
                    Image(systemName: "stop.fill")
                        .imageScale(.large)
                }
            }
        }
    }
    
    func sendMusic(){
        do{
            let data: Data = try Data(contentsOf: audioURL)
            let result = client.send(data: data)
            print(result)
        }catch{
            print("💩")
        }
        
        var dataRec = client.read(1024 * 4)
        while dataRec == nil{
            dataRec = client.read(1024 * 4)
        }
        self.acc = dataRec!.withUnsafeBytes { $0.load(as: Float.self) }
        sent = true
        
        
        
        
    }
    
    func floatValue(data: Data) -> Float {
        return Float(bitPattern: UInt32(bigEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) }))
    }
}

struct Recording {
    let fileURL: URL
    let createdAt: Date
}

extension Float {
    func truncate(places : Int)-> Float {
        return Float(floor(pow(10.0, Float(places)) * self)/pow(10.0, Float(places)))
    }
}
