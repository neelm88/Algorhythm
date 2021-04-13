//
//  ContentView.swift
//  Algorhythm
//
//  Created by Dan Bellini on 2/9/21.
//

import Foundation
import SwiftUI



struct SongSelectionView : View{
    
    @State var songs : [SongInfo] = []
    @StateObject var addedSong : AddedSong = AddedSong()
    var body: some View {
        NavigationView{
            VStack{
                NavigationLink(destination: NewSongView()) {
                    Text("New Song")
                    .onAppear(perform: {
                        if addedSong.added{
                            print("here")
                            do{
                                songs = try JSONDecoder().decode([SongInfo].self, from: FilesManager().read(fileNamed: "SongsList.txt"))
                                }catch{
                                    print(" read error")
                            }
                            addedSong.added = false
                        }
                        })
                }
                List {
                    ForEach(songs, id: \.name) { song in
                        NavigationLink(destination: SongView(song: song, audioRecorder: AudioRecorder(songName: "\(song.artist)\(song.name)"))) {
                            SongRow(info: song)
                                
                        }
                    }
                    .onDelete(perform: { indexSet in
                        songs.remove(atOffsets: indexSet)
                        var coded : Data
                        do {
                            coded =  try JSONEncoder().encode(songs)
                            try FilesManager().save(fileNamed: "SongsList.txt", data: coded)
                            print("data wrote!")
                        }catch{
                            print("write error")
                        }
                    })
                }
                
                
            }
            .navigationBarTitle(Text("Songs"))
            
            
        }
        .environmentObject(addedSong)
        
    }
    
    
}
