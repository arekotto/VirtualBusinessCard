//
//  ButtonStyle.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

enum ScreenSizeType {
    case compact
    case medium
    case large
}

struct ShrinkOnTapButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
}

struct AppDefaultButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
//            .font(Font.appDefault(size: 20, weight: .medium))
            .foregroundColor(Color.appAccent)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
}

struct StrongFilledRoundedButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
//            .font(Font.appDefault(size: 20, weight: .medium, design: .default))
            .background(Color.appAccent)
            .foregroundColor(Color.white)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
}

struct LightFilledRoundedButtonStyle: ButtonStyle {
    
    var disabled: Bool = false
    
    var isCompactLayout: Bool {
        UIScreen.main.bounds.width <= 375
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        let mainColor: Color = disabled ? .appGray : .appAccent
        return configuration.label
            .font(Font.appDefault(size: isCompactLayout ? 18 : 24, weight: .medium))
            .background(mainColor.opacity(0.1))
            .foregroundColor(mainColor)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
}

struct BorderedRoundedButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
//            .font(Font.appDefault(size: Font.textSize(textStyle: .title1), weight: .medium, design: .default))
            .foregroundColor(Color.appAccent)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appAccent, lineWidth: 2)
                    .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
        )
    }
}
