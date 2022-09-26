//
//  SliderView.swift
//  Instafilter
//
//  Created by sal on 9/22/22.
//

import SwiftUI


struct FilterControlView: View {
    
    @EnvironmentObject var ph:PhotoHandler
        
    var body: some View {
        VStack {
            Text("Current Filter:  \(ph.filterType.rawValue)")
                .font(.title2).bold()
                .padding()
                .foregroundColor(.primary)
                
            HStack(alignment: .center) {
                Text(ph.filterInputs[0].name)
                    .font(.title2)
                Slider(value: $ph.filterInputs[0].value, in:ph.filterInputs[0].range)
            }
            .sliderStyle_sal1()
            .onChange(of: ph.filterInputs[0].value) { _ in
                ph.setFilterInputLevel(ph.filterInputs[0].type, value:ph.filterInputs[0].value)
            }
            if (ph.filterInputs.indices.contains(1)) {
                HStack(alignment: .center) {
                    Text(ph.filterInputs[1].name)
                        .font(.title2)
                    Slider(value: $ph.filterInputs[1].value, in:ph.filterInputs[1].range)

                }
                .sliderStyle_sal1()
                .onChange(of: ph.filterInputs[1].value) { _ in
                    ph.setFilterInputLevel(ph.filterInputs[1].type, value:ph.filterInputs[1].value)
                }
            }
        }
    }
}

struct FilterControlView_Previews: PreviewProvider {
    static var previews: some View {
        FilterControlView()
    }
}

