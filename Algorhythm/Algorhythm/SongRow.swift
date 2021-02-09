//
//  SongRow.swift
//  Algorhythm
//
//  Created by Dan Bellini on 2/9/21.
//

import Foundation
import SwiftUI

struct SongInfo{
    var name : String
    var artist : String
}

struct SongRow : View{
    var info : SongInfo
    
    var body : some View {
        VStack(alignment: .leading){
            Text(info.name).font(.title)
            Text(info.artist).font(.subheadline)
        }
    }
}
