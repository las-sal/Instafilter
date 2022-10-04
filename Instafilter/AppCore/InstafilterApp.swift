//
//  InstafilterApp.swift
//  Instafilter
//
//  Created by sal on 9/14/22.
//
// This is Project 13 of 100 days of SwiftUI on hackingwithswift.com.
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
