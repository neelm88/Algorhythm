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
    
    @State var client = TCPClient(address: "www.apple.com", port: 80)
    
    
    
    
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
                                    RecordingsView(audioRecorder: audioRecorder)
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
        audioRecorder.stopRecording()
        let data: Data = imageViews[0].image.pngData()!
        let result = client.send(data: data)
        print(result)
        
    }
        
    }


struct RecordingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioRecorder : AudioRecorder
    var body: some View {
        List {
            ForEach(audioRecorder.recordings, id: \.createdAt) { recording in
                RecordingRow(audioURL: recording.fileURL)
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
    
    @ObservedObject var audioPlayer = AudioPlayer()
    
    var body: some View {
        HStack {
            Text("\(audioURL.lastPathComponent)")
            Spacer()
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
}

struct Recording {
    let fileURL: URL
    let createdAt: Date
}
