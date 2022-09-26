//
//  SalSectionTitle.swift
//  FriendFace
//
//  Created by sal on 9/11/22.
//

import SwiftUI


struct CapsuleText: View {
    var text: String
    var color:Color

    var body: some View {
        Text(text)
            .font(.largeTitle)
            .padding()
            .foregroundColor(.white)
            .background(color)
            .clipShape(Capsule())
    }
}

struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.white)
            .background(.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ButtonStyle_sal1: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth:.infinity)
            .font(.title3)
            .buttonStyle(.borderedProminent)
           // .cornerRadius(15)
            .shadow(radius: 20, y: 6)        
    }
}

extension Button {
    func buttonStyle_sal1() -> some View {
        modifier(ButtonStyle_sal1())
    }
}

struct SliderStyle_sal1: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.secondary)
            .cornerRadius(20)
            .shadow(radius: 20, y: 6)
        
    }
}

extension View {
    func sliderStyle_sal1() -> some View {
        modifier(SliderStyle_sal1())
    }
}


