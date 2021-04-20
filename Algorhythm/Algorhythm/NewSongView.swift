//
//  NewSongView.swift
//  Algorhythm
//
//  Created by Dan Bellini on 2/9/21.
//

import Foundation
import SwiftUI
import PhotosUI
import SwiftSocket

struct NewSongView : View{
    @State var currSongs : [SongInfo] = []
    @State var song : SongInfo?
    @State var isLinkActive = false
    @State public var name : String = ""
    @State public var artist : String = ""
    @State private var isShowImageSelector = false
    @State public var imageIsSelected = false
    @State var images : [UIImage] = []
    @State var imageViews : [ImageView] = [ImageView(image: UIImage())]
    @State private var pickerType : UIImagePickerController.SourceType = .photoLibrary
    @EnvironmentObject var addedSong : AddedSong
    
    @State var client = TCPClient(address: "127.0.0.1", port: 8080)
    
    var body : some View {
        ScrollView(.vertical){
            VStack{
                    Text("Create New Song").font(.title)
                    Spacer()
                    
                    Button(action: {
                        do{
                            currSongs = try JSONDecoder().decode([SongInfo].self, from: FilesManager().read(fileNamed: "SongsList.txt"))
                            print("hello")
                        }catch{
                                print(" read error")
                        }
                        self.song = SongInfo(photos: imageViews, name: name, artist: artist)
                        self.currSongs.append(self.song!)
                        var coded : Data
                        do {
                            coded =  try JSONEncoder().encode(currSongs)
                            try FilesManager().save(fileNamed: "SongsList.txt", data: coded)
                            print("data wrote!")
                        }catch{
                            print("write error")
                        }
                        isLinkActive = true
                        self.addedSong.added = true
                        
                        for i in images{
                            switch client.send(data: i.pngData()!){
                            case .success:
                                print("image sent!")
                            case .failure(let error):
                                print(error)
                                print("x💩")
                            }
                        }
                        
                        //read response
                    }){
                        HStack{
                            Text("Save")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                        .background(saveButtonColor)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        }
                    .disabled(!imageIsSelected || name == "" || artist == "")
                NavigationLink(destination: SongView(song: song ?? SongInfo(photos: imageViews, name: name, artist: artist), audioRecorder: AudioRecorder(songName: "\(song?.artist)\(song?.name)")), isActive: $isLinkActive) {
                            SongRow(info: song ?? SongInfo(photos: imageViews, name: name, artist: artist))
                    }
                    .hidden()
                    
          
                    VStack{
                        TextField("Name", text: $name)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                        TextField("Artist", text: $artist).disableAutocorrection(true)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    }
                if imageIsSelected{
                    PageView(pages: imageViews)
                        .aspectRatio(contentMode: .fit)
                }
                Button(action: {
                    self.isShowImageSelector = true
                    self.pickerType = .photoLibrary
                }) {
                    HStack {
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                 
                        Text("Photo Library")
                            .font(.headline)
                        }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                Spacer()
                Button(action: {
                    self.isShowImageSelector = true
                    self.pickerType = .camera
                }) {
                    HStack {
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                 
                        Text("Take Image")
                            .font(.headline)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                
                
            }
            
        }
        .sheet(isPresented: $isShowImageSelector) {
            PhotoPicker(images: images, view: self)
        }
        .onAppear(perform: {
            imageViews  = [ImageView(image: UIImage())]
            images = []
            imageIsSelected = false
            currSongs = []
            artist = ""
            name = ""
            song = nil
            isLinkActive = false
            
            switch client.connect(timeout: 10) {
               case .success:
                 print("yay")
               case .failure(let error):
                 print("💩")
             }
        })
    }
    
    var saveButtonColor : Color {
        if !imageIsSelected || name == "" || artist == "" {
            return Color.gray
        }else{
            return Color.blue
        }
    }
}

struct ImageView : View {
    var image : UIImage
    
    var body: some View{
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

class AddedSong : ObservableObject {
    @Published var added = true
}


