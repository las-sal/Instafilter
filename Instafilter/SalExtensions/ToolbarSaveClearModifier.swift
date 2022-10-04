//
//  MainToolbarView.swift
//  Instafilter
//
//  Created by sal on 10/3/22.
//

import SwiftUI

struct ToolbarSaveClearModifier: ViewModifier {
    
    @EnvironmentObject var ph:PhotoHandler
    @State private var bShowSaveAlert = false
    @State private var saveAlertMessage = ""
    @Binding var selectedFilter:String?
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    
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
                    .disabled(ph.displayImage == nil)//should be a call to ph to see if there are changes to save
                    .alert("Save", isPresented: $bShowSaveAlert) {
                        
                        Button("OK", role:.cancel) {}
                        
                    } message: {
                        Text(saveAlertMessage)
                    }
                    
                    Button("Clear") {
                        ph.resetImage()
                        ph.setFilter(.none)
                        selectedFilter = nil
                    }
                }
            }
    }
}

extension View {
    func toolbarSaveClear(selectedFilter:Binding<String?>) -> some View {
        modifier(ToolbarSaveClearModifier(selectedFilter:selectedFilter))
    }
}
