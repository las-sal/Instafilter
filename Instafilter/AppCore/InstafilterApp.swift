//
//  InstafilterApp.swift
//  Instafilter
//
//  Created by sal on 9/14/22.
//

import SwiftUI

@main
struct InstafilterApp: App {
    
    @StateObject private var ph = PhotoHandler()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(ph)
        }
    }
}
