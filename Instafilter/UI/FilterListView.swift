//
//  FilterListView.swift
//  Instafilter
//
//  Created by sal on 9/29/22.
//

import SwiftUI


struct FilterListView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var ph:PhotoHandler
    @Binding var selectedFilter: String?
    
    var body: some View {
        List(FilterType.listOfFilters(), id:\.self) { filter in
            Button(filter) {
                selectedFilter = filter
                presentationMode.wrappedValue.dismiss()
            }
        }
        .background(.ultraThickMaterial)
    }
}

struct FilterListView_Previews: PreviewProvider {
    static var previews: some View {
        FilterListView(selectedFilter: .constant("Sepia Tone"))
    }
}
