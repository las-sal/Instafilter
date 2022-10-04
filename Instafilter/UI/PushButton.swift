//
//  PushButton.swift
//  Instafilter
//
//  Created by sal on 9/26/22.
//

import SwiftUI

struct PushButton: View {
    let title: String
    @Binding var isOn: Bool

    var onColors = [Color(white: 1.0), Color(white: 0.8)]
    var offColors = [Color(white: 0.6), Color(white: 0.4)]

    var body: some View {
        Button(title) {
            isOn.toggle()
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: isOn ? onColors : offColors), startPoint: .top, endPoint: .bottom))
        .foregroundColor(isOn ? .black : .white)
        .cornerRadius(8)
        .shadow(radius: 5)
    }
}

struct PushButton_Previews: PreviewProvider {
    static var previews: some View {
        PushButton(title:"Test", isOn: .constant(false))
    }
}
