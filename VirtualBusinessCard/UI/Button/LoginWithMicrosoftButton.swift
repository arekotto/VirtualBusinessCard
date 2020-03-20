//
//  LoginWithMicrosoftButton.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 19/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct LoginWithMicrosoftButton: View {
    
    let title: String

    var body: some View {
        HStack {
            Image("MicrosoftLogo")
                .interpolation(.high)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .padding(Self.logoPadding)
                .background(Color.white)
            Spacer()
            Text(title)
                .frame(alignment: .center)
                .fixedSize()
                .font(Font.appDefault(size: Self.fontSize, weight: .medium))
                .lineLimit(1)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .aspectRatio(1, contentMode: .fit)
                .padding(Self.logoPadding)
        }
        .frame(minWidth: 100, maxWidth: .infinity)
        .frame(height: Self.height)
        .foregroundColor(.white)
        .background(Color.microsoftBlue)
        .cornerRadius(Self.height / 3)
        .overlay(
            RoundedRectangle(cornerRadius: Self.height / 3)
                .stroke(Color.microsoftBlue, lineWidth: 2)
        )
    }

}

extension LoginWithMicrosoftButton {
    static var logoPadding: CGFloat {
        switch DeviceDisplay.sizeType {
        case .compact: return 14
        default: return 16
        }
    }
    
    static var fontSize: CGFloat {
        switch DeviceDisplay.sizeType {
        case .compact: return 16
        case .standard: return 18
        case .commodious: return 22
        }
    }
    
    static var height: CGFloat {
        switch DeviceDisplay.sizeType {
        case .compact: return 44
        default: return 56
        }
    }
    
    static var font: Font {
        Font.appDefault(size: fontSize, weight: .medium)
    }
}

struct LoginWithMicrosoftButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginWithMicrosoftButton(title: "Log in with Microsoft")
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .dark)
            
            LoginWithMicrosoftButton(title: "Log in with Microsoft")
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }    }
}
