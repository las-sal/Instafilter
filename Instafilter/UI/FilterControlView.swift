//
//  SliderView.swift
//  Instafilter
//
//  Created by sal on 9/22/22.
//

import SwiftUI

//
// FilterControlView
//
struct FilterControlView: View {
    
    @EnvironmentObject var ph:PhotoHandler
        
    var body: some View {
        VStack {
            if (ph.filterInputs.indices.contains(0)) {
                
                HStack(alignment: .center) {
                    // getting here when filter type is none and there are no inputs in the
                    // array causing an out of range exception. happens when i select and then
                    // deselect a picker from the filter. i have
                    Text(ph.filterInputs[0].name)
                        .font(.title2)
                    Slider(value: $ph.filterInputs[0].value, in:ph.filterInputs[0].range)
                        .sliderStyle_sal1()
                }
                .onChange(of: ph.filterInputs[0].value) { _ in
                    ph.setFilterInputLevel(ph.filterInputs[0].type, value:ph.filterInputs[0].value)
                }
            }

            if (ph.filterInputs.indices.contains(1)) {
                
                HStack(alignment: .center) {
                    Text(ph.filterInputs[1].name)
                        .font(.title2)
                    Slider(value: $ph.filterInputs[1].value, in:ph.filterInputs[1].range)
                        .sliderStyle_sal1()
                }

                .onChange(of: ph.filterInputs[1].value) { _ in
                    ph.setFilterInputLevel(ph.filterInputs[1].type, value:ph.filterInputs[1].value)
                }
            }
         /*   ForEach(0..<2) { i in
                
               if (ph.filterInputs.indices.contains(i)) {
                   
                   HStack(alignment: .center) {
                       Text(ph.filterInputs[i].name)
                           .font(.title2)
                       Slider(value: $ph.filterInputs[i].value, in:ph.filterInputs[i].range)
                           .sliderStyle_sal1()
                   }

                   .onChange(of: ph.filterInputs[i].value) { _ in
                       print("Slider: \(ph.filterInputs[i].type.rawValue) changed to \(ph.filterInputs[i].value).")
                       ph.setFilterInputLevel(ph.filterInputs[i].type, value:ph.filterInputs[i].value)
                   }
               }
            }*/
        }
    }
}

struct FilterControlView_Previews: PreviewProvider {
    static var previews: some View {
        FilterControlView()
    }
}

