//
//  ContentView.swift
//  Instafilter
//
//  Created by sal on 9/14/22.
//

import SwiftUI


struct MainView: View {
        
    var body: some View {
        NavigationView {
            VStack {
                Divider()
                    .background(.ultraThinMaterial)
                Spacer()
                PhotoStackView()
                Spacer()
                FilterControlView()
               // ButtonView()
            }
            .navigationTitle("Instafilter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button() {
                        
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Change Filter") {
                       // bShowFilterSheet = true
                    }
                 //   .buttonStyle_sal1()
                    
                    Button("Save") {
                        
                    /*    ph.saveImage() { error in
                            if let error = error {
                                saveAlertMessage = "Save Failed. Error \(error.localizedDescription)."
                            }
                            else {
                                saveAlertMessage = "Save Succeeded!"
                            }
                            bShowSaveAlert = true
                        }*/
                    }
                 //   .buttonStyle_sal1()
                //    .disabled(ph.processedImage == nil)
                    Button("Clear") {
                  //      bShowFilterSheet = true
                    }
                    .buttonStyle_sal1()
                }

            }
            .background(.ultraThickMaterial)
            .tint(Color.primary)
          //  .padding([.bottom])
        }
        .preferredColorScheme(.dark)
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
