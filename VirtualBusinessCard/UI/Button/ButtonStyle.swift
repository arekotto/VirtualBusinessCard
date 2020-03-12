//
//  ButtonStyle.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct AppDefaultButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.system(size: 20, weight: .medium, design: .default))
            .foregroundColor(Color.accent)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
}

struct StrongFilledRoundedButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.system(size: 20, weight: .medium, design: .default))
            .background(Color.accent)
            .foregroundColor(Color.white)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
}

struct LightFilledRoundedButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.system(size: 20, weight: .medium, design: .default))
            .background(Color.accent.opacity(0.1))
            .foregroundColor(.accent)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
}

struct BorderedRoundedButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.system(size: 20, weight: .medium, design: .default))
            .foregroundColor(Color.accent)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accent, lineWidth: 2)
                    .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
        )
    }
}
