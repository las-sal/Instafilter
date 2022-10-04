//
//  RadioMultiButton.swift
//  Instafilter
//
//  Created by sal on 9/27/22.
//

import SwiftUI

//
// RadioMultiButton
//
// Takes a string of button titles. The number of titles in the string define
// the number of buttons in the set. The binding must convey the selection
// back to the caller. The binding gives the index back into the array of
// strings that was sent - i'm presuming the order will be preserved. I'd rather
// send back the filter enum - maybe i will - no longer generic. maybe i can
// send in a closure to translate the index to an enum - seems like a good idea.
//
struct ScrollingPicker: View {
    let titles: [String]
    let finalTitle: String
    @Binding var selectedFilter: String?
    
    var onColors = [Color(white: 1.0), Color(white: 0.7)]
    var offColors = [Color(white: 0.6), Color(white: 0.3)]
    
    var onFinalColors = [Color(red: 1.0, green: 1.0, blue: 1.0),
                         Color(red: 0.5, green: 0.5, blue: 0.7)]
    var offFinalColors = [Color(red: 0.3, green: 0.5, blue: 0.8),
                         Color(red: 0.1, green: 0.3, blue: 0.6)]
    
    
    func clearSelection() {
        selectedFilter = nil
    }
    
    var body: some View {
        HStack {
            ZStack (alignment: .trailing) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 3) {
                     
                        ForEach (titles, id:\.self) { title in
                            Button(title) {
                                
                                selectedFilter = (selectedFilter == title) ? nil : title
                                
                             /*   if selectedFilter == title {
                                    selectedFilter = nil
                                }
                                else {
                                    selectedFilter = title
                                }*/
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 4)
                            .background(LinearGradient(gradient: Gradient(colors: (selectedFilter == title) ? onColors : offColors), startPoint: .top, endPoint: .bottom))
                            .foregroundColor((selectedFilter == title) ? .black : .white)
                            .cornerRadius(1)
                            .shadow(radius: 5)
                        }
                        NavigationLink(finalTitle, destination: FilterListView(selectedFilter:$selectedFilter))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        .background(LinearGradient(gradient: Gradient(colors: (selectedFilter == finalTitle) ? onFinalColors : offFinalColors), startPoint: .top, endPoint: .bottom))
                        .foregroundColor((selectedFilter == finalTitle) ? .black : .white)
                        .cornerRadius(1)
                        .shadow(radius: 5)
                    }
                    .padding(4)

                }
            }
        }
    }
}

struct ScrollingPicker_Previews: PreviewProvider {
    static var previews: some View {
        ScrollingPicker(titles:["Test1", "Test2", "Test3"], finalTitle: "More...", selectedFilter: .constant("") )
    }
}
