//
//  SongRow.swift
//  Algorhythm
//
//  Created by Dan Bellini on 2/9/21.
//

import Foundation
import SwiftUI

struct SongInfo : Codable{
    var name : String
    var artist : String
    var photo: [Data]
        
    public init(photos: [ImageView], name: String, artist: String) {
        photo = []
        for image in photos{
            if image.image != UIImage(){
                photo.append(image.image.pngData()!)
            }
            
        }
        self.name = name
        self.artist = artist
    }
    
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
