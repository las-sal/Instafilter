//
//  PhotoStackView.swift
//  Instafilter
//
//  Created by sal on 9/20/22.
//

import SwiftUI

//
// PhotoStackView
//
// Shows a message to select a photo or the photo selected from the image
// picker. Depends on PhotoHandler to store and manage photos. When a
// new image is selected, the filter is cleared - the user must reselect
// a filter.
//
struct PhotoStackView: View {
    
    @EnvironmentObject var ph:PhotoHandler
    @State var pickerImage_ui:UIImage?
    @State var bShowingImagePicker = false
    @Binding var selectedFilter:String?
    
    var body: some View {
        ZStack {
            
            VStack {
                Text("Tap to select a picture")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        
            // This image view is optional. if its nil, then the details beneath it will display, if not
            // the image will. image? with a zstack is a great idea
            VStack {
                Spacer ()
                ph.displayImage?
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth:.infinity)
                Spacer()
            }
        }
        .onTapGesture {
            bShowingImagePicker = true
        }
        .sheet(isPresented: $bShowingImagePicker) {
            ImagePicker(image_ui: $pickerImage_ui)
        }
        .onChange(of: pickerImage_ui) { _ in
            // If there is a new image, load it in the photo
            // handler and clear out the filter.
            ph.loadNewImage(pickerImage_ui)
            ph.setFilter(.none)
            selectedFilter = nil //TODO: find a better way to do this.
        }
    }
}

struct PhotoStackView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoStackView(selectedFilter: .constant("Sepia Tone"))
    }
}
