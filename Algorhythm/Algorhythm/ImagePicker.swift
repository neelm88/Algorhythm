//
//  ImagePicker.swift
//  Algorhythm
//
//  Created by Dan Bellini on 2/11/21.
//

import Foundation
import SwiftUI
import UIKit


struct ImagePicker: UIViewControllerRepresentable {
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode
    
    var sourceType : UIImagePickerController.SourceType = .photoLibrary
    var view : NewSongView
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
 
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
         
        return imagePicker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        if selectedImage != UIImage(){
            view.imageIsSelected = true
        }
 
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     
        var parent: ImagePicker
     
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
     
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
     
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


