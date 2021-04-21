//
//  TabView.swift
//  Algorhythm
//
//  Created by Dan Bellini on 4/5/21.
//

import Foundation
import SwiftUI

struct TabsView: View {
    var body: some View {
        TabView {
            
            SongSelectionView()
                .tabItem {
                    Label("Record", systemImage: "list.dash")
                }

            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "square.and.pencil")
                }
            
            TunerView()
                .tabItem{
                    Label("Tune", systemImage: "list.dash")
                }
        }
            
    }
}
