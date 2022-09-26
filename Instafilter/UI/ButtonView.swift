//
//  ButtonView.swift
//  Instafilter
//
//  Created by sal on 9/23/22.
//

import SwiftUI

struct ButtonView: View {
    
    @EnvironmentObject var ph:PhotoHandler
    
    @State private var bShowFilterSheet = false
    @State private var bShowSaveAlert = false
    @State private var saveAlertMessage = ""

    var body: some View {
        HStack {
            Button("Change Filter") {
                bShowFilterSheet = true
            }
            .buttonStyle_sal1()
            
            Button("Save") {
                
                ph.saveImage() { error in
                    if let error = error {
                        saveAlertMessage = "Save Failed. Error \(error.localizedDescription)."
                    }
                    else {
                        saveAlertMessage = "Save Succeeded!"
                    }
                    bShowSaveAlert = true
                }
            }
            .buttonStyle_sal1()
            .disabled(ph.processedImage == nil)
            Button("Clear") {
                bShowFilterSheet = true
            }
            .buttonStyle_sal1()
        }
        .font(.title)
        .padding([.horizontal, .top], 30)
        .confirmationDialog("Select a filter", isPresented: $bShowFilterSheet) {
            
            Button("Crystallize") { ph.setFilter(.crystallize) }
            Button("Edges") { ph.setFilter(.edges) }
            Button("Gaussian Blur") { ph.setFilter(.gaussianBlur) }
            Button("Pixellate") { ph.setFilter(.pixellate) }
            Button("Sepia Tone") { ph.setFilter(.sepiaTone) }
            Button("Unsharp Mask") { ph.setFilter(.unsharpMask) }
            Button("Vignette") { ph.setFilter(.vignette) }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Save", isPresented: $bShowSaveAlert) {
            
            Button("OK", role:.cancel) {}
            
        } message: {
            Text(saveAlertMessage)
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView()
    }
}
