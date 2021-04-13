//
//  NewImagePicker.swift
//  Algorhythm
//
//  Created by Dan Bellini on 2/25/21.
//

import Foundation
import SwiftUI
import UIKit
import PhotosUI


struct PhotoPicker: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = PHPickerViewController
            
            var images: [UIImage]
            var itemProviders: [NSItemProvider] = []
            var view : NewSongView
            
            func makeUIViewController(context: Context) -> PHPickerViewController {
                    var configuration = PHPickerConfiguration()
                    configuration.selectionLimit = 10
                    configuration.filter = .images
                    let picker = PHPickerViewController(configuration: configuration)
                    picker.delegate = context.coordinator
                    return picker
            }
            
            func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
            
            }
    
            
            func makeCoordinator() -> Coordinator {
                    return PhotoPicker.Coordinator(parent: self)
            }
            
            class Coordinator: NSObject, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
                    
                    var parent: PhotoPicker
                    
                    init(parent: PhotoPicker) {
                            self.parent = parent
                    }
                    
                    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                            picker.dismiss(animated: true)
                            if !results.isEmpty {
                                    parent.itemProviders = []
                                    parent.images = []
                            }
                            parent.itemProviders = results.map(\.itemProvider)
                            loadImage()
                            
                        
                    }
                    
                    private func loadImage() {
                            var counter = 0
                            for itemProvider in parent.itemProviders {
                                    counter = counter + 1
                                    if itemProvider.canLoadObject(ofClass: UIImage.self) {
                                            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                                                    if let image = image as? UIImage {
                                                       
                                                        if(self.parent.view.images.count == 0){
                                                            self.parent.view.imageViews = []
                                                        }
                                                        self.parent.view.images.append(image)
                                                            //self.parent.view.images = self.parent.images
                                                        self.parent.view.imageViews.append(ImageView(image: image))
                                                        if(counter == self.parent.itemProviders.count){
                                                            self.parent.view.imageIsSelected = true
                                                        }
                                                        
                                                       
                                                    } else {
                                                            print("Could not load image", error?.localizedDescription ?? "")
                                                    }
                                                
                                            }
                                    }
                                
                            }
                        
                    }
            }

}



