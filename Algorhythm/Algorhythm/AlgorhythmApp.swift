//
//  AlgorhythmApp.swift
//  Algorhythm
//
//  Created by Dan Bellini on 2/2/21.
//

import SwiftUI






@main
struct AlgorhythmApp: App {
    init(){
        
//        var songs : [SongInfo] = []
//        var coded : Data
//        do {
//            coded =  try JSONEncoder().encode(songs)
//            try FilesManager().save(fileNamed: "SongsList.txt", data: coded)
//            print("data wrote!")
//        }catch{
//            print("write error")
//        }
    }
    var body: some Scene {
        WindowGroup{
            TabsView()
        }
    }
}
