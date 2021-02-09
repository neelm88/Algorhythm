//
//  ContentView.swift
//  Algorhythm
//
//  Created by Dan Bellini on 2/9/21.
//

import Foundation
import SwiftUI


let songs = [
    SongInfo(name: "Run to the Hills", artist: "Iron Maiden"),
    SongInfo(name: "Spit out the Bone", artist: "Metalica")
]
struct SongSelectionView : View{
    var body: some View {
        NavigationView{
            VStack{
                NavigationLink(destination: NewSongView()) {
                    Text("New Song")
                }
                List(songs, id: \.name) { song in
                    SongRow(info: song)
                }
            }
            .navigationBarTitle(Text("Songs"))
        }
    }
}
