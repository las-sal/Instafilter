//
//  ImageSaver.swift
//  Instafilter
//
//  Created by sal on 9/15/22.
//

import SwiftUI

//
// ImageSaver
//
// Class provided by Paul Hudson from HWS to save an image to a user's
// photo album. One change made was to receive a closure for calling
// back the caller with the result of the save to enable UI elemeents
// around saving. In this app, the closure is passed down from the
// save button press closure. Its a good example of how closures
// keep the context from which they were originally called.
//
class ImageSaver: NSObject {
    
    init(handler: ((Error?) -> Void)?) {
        resultHandler = handler
    }
    
    var resultHandler:((Error?) -> Void)?
    
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("save complete")
        
        // This is a great optional feature of swift. If resultHandler is nil, the entire
        // statement is simply dropped. if it exists, then the function is called.
        resultHandler?(error)
    }
}
