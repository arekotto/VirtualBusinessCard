//
//  LoginWithAppleButton.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct LoginWithAppleButton: View {
    
    let title: String
    
    var body: some View {
            HStack {
                Image("AppleLogo")
                    .interpolation(.high)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                Spacer()
                Text(title)
                    .frame(alignment: .center)
                    .fixedSize()
                    .font(Font.appDefault(size: Self.isCompactLayout ? 16 : 22, weight: .medium))
                    .lineLimit(1)
                Spacer()
                Spacer()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .aspectRatio(1, contentMode: .fit)
            }
            .frame(minWidth: 100, maxWidth: .infinity)
            .frame(height: Self.isCompactLayout ? 44 : 56)
            .foregroundColor(Self.forgroundColor)
            .background(Self.backgroundColor)
            .cornerRadius(Self.isCompactLayout ? 16 : 20)
    }
}

extension LoginWithAppleButton {
    
    static var isCompactLayout: Bool {
        UIScreen.main.bounds.width <= 375
    }
    
    static var backgroundColor: Color {
        Color(UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .white
            } else {
                return .black
            }
        })
    }
    
    static var forgroundColor: Color {
        Color(UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .black
            } else {
                return .white
            }
        })
    }
}

struct LoginWithAppleButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginWithAppleButton(title: "Log in with Apple")
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .dark)
            
            LoginWithAppleButton(title: "Log in with Apple")
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }    }
}
