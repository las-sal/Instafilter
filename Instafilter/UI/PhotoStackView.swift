//
//  PhotoStackView.swift
//  Instafilter
//
//  Created by sal on 9/20/22.
//

import SwiftUI


struct PhotoStackView: View {
    
    @EnvironmentObject var ph:PhotoHandler
    
    @State var pickerImage_ui:UIImage?
    @State var bShowingImagePicker = false
    
    var body: some View {
        ZStack {
            
            //Spacer()
            
            Text("Tap to select a picture")
                .font(.largeTitle)
                .foregroundColor(.primary)
        
            // This image view is optional. if its nil, then the details beneath it will display, if not
            // the image will. image? with a zstack is a great idea
            ph.processedImage?
                .resizable()
                .frame(maxWidth:.infinity)
                .scaledToFit()
        }
       // .shadow(radius: 10, y: 5)
        .onTapGesture {
            bShowingImagePicker = true
        }
        .sheet(isPresented: $bShowingImagePicker) {
            ImagePicker(image_ui: $pickerImage_ui)
        }
        .onChange(of: pickerImage_ui) { _ in
            ph.loadAndProcessImage(pickerImage_ui)
        }
    }
}


struct PhotoStackView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoStackView()
    }
}
