//
//  ContentView.swift
//  Instafilter
//
//  Created by sal on 9/14/22.
//

import SwiftUI


struct MainView: View {
    
    @EnvironmentObject var ph:PhotoHandler
    @State var selectedFilter:String?
    
    var body: some View {
        NavigationView {
            VStack {

                PhotoStackView(selectedFilter:$selectedFilter)
                FilterControlView()
                ScrollingPicker(titles:ph.top5Filters, finalTitle:"More...", selectedFilter:$selectedFilter)
            }
            .navigationTitle("Instafilter")
            .navigationBarTitleDisplayMode(.inline)

            .background(.ultraThickMaterial)
            .tint(Color.primary)
        }
        .preferredColorScheme(.dark)
        .toolbarSaveClear(selectedFilter:$selectedFilter)
        .onChange(of: selectedFilter) { _ in
                
            guard let selectedFilter = selectedFilter else {
                print("OCO_selectedFilter: selectedFilter unwrap failed")
                ph.setFilter(.none)
                return
            }
            
            if let newFilter = FilterType(rawValue: selectedFilter) {
                ph.setFilter(newFilter)
            }
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
