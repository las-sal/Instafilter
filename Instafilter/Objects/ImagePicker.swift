//
//  ImagePicker.swift
//  Instafilter
//
//  Created by sal on 9/15/22.
//

import SwiftUI
import PhotosUI

//
// ImagePicker
//
// Based on original class provided in project 13 of Paul Hudson's HWS 100 days of SwiftUI.
//
// UIViewControllerRepresentable: protocol builds on View, which means the struct we’re
// defining can be used inside a SwiftUI view hierarchy, however we don’t provide a body
// property because the view’s body is the view controller itself – it just shows whatever
// UIKit sends back. Protocol requires two functions:
//
//    makeUIViewController, updateUIViewController
//
// Since swiftui MUST know the type, we make it clear in the method definitions what
// viewcontroller we are returning. I think there was also a type alias that could
// be filled out to call out the type.
//
struct ImagePicker : UIViewControllerRepresentable {
    
    @Binding var image_ui: UIImage?
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        var parent:ImagePicker
        init(_ parent:ImagePicker) {
            self.parent = parent
        }
        
        //
        // picker is a reference to the picker this call is coming from. results will have
        // an array of images that were selected
        //
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            // The fact we are receiving this call means the user has completed interacting with
            // the picker and we can dissmiss it. because we are receiving a reference through
            // the delegate, its easy enough to call teh dismiss method on our reference. below
            // when we made the picker, we did not store it in ImagePicker but just returned
            // the reference to the caller of makeUIViewController...
            picker.dismiss(animated: true)
            
    
            // if nothing is selected, we can just return since the only necessary action
            // is to dismiss the picker and we've already done it.
            guard let provider = results.first?.itemProvider else {return}
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image_ui = image as? UIImage
                }
            }
        }

    }
    
    //
    // makeCoordinator
    //
    // SwiftUI automatically calls this when ImagePicker is created. I guess it sees
    // its a ViewController respresetnation and looks for the makeCoordinator function
    // to see if the struct will provide a coordinator to be the delegate.
    //
    // We are passing self in here so the Coordinator can reference properties of the
    // ImagePicker - since the Coordinator is acting as the delegate for the ImagePicker
    // and will need to do some stuff based on how the user interacts with the ImagePicker
    //
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    //
    // makeUIViewController
    //
    func makeUIViewController(context: Context) -> PHPickerViewController {
        
        var config = PHPickerConfiguration()
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        
        // swiftui made a coordinator by calling our makeCoordinator function and now
        // we are assigning that Coordinator to be the delegate for the image picker view
        picker.delegate =  context.coordinator
        
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}
