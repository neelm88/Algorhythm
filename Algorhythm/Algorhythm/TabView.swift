//
//  TabView.swift
//  Algorhythm
//
//  Created by Dan Bellini on 4/5/21.
//

import Foundation
import SwiftUI

struct TabsView: View {
    @State var tabSelection = 1
    var body: some View {
        TabView(selection: $tabSelection){
            
            SongSelectionView()
                .tabItem {
                    Label("Record", systemImage: "mic")
                }
                .tag(1)

            ChatView(tabNum: $tabSelection)
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
                .tag(2)
            
            TunerView()
                .tabItem{
                    Label("Tune", systemImage: "music.note")
                }
                .tag(3)
        }
            
    }
}
