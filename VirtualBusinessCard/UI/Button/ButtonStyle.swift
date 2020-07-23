//
//  ButtonStyle.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct ShrinkOnTapButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
}

struct AppDefaultButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.appDefault(size: Self.fontSize, weight: .medium))
            .foregroundColor(Color.appAccent)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
    
    static var fontSize: CGFloat {
        switch DeviceDisplay.sizeType {
        case .compact: return 16
        case .standard: return 18
        case .commodious: return 22
        }
    }
}

struct StrongFilledRoundedButtonStyle: ButtonStyle {
    
    static var fontSize: CGFloat {
        switch DeviceDisplay.sizeType {
        case .compact: return 16
        case .standard: return 18
        case .commodious: return 22
        }
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.appDefault(size: Self.fontSize, weight: .medium))
            .background(Color.appAccent)
            .foregroundColor(Color.white)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
}

struct LightFilledRoundedButtonStyle: ButtonStyle {
    
    static var fontSize: CGFloat {
        switch DeviceDisplay.sizeType {
        case .compact: return 16
        case .standard: return 18
        case .commodious: return 22
        }
    }
    
    var disabled: Bool = false
    
    var isCompactLayout: Bool {
        UIScreen.main.bounds.width <= 375
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        let mainColor: Color = disabled ? .appGray : .appAccent
        return configuration.label
            .font(Font.appDefault(size: Self.fontSize, weight: .medium))
            .background(mainColor.opacity(0.1))
            .foregroundColor(mainColor)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
    }
}

struct BorderedRoundedButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
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
