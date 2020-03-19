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
                .padding(Self.isCompactLayout ? 14 : 16)
                .background(Color.white)
            Spacer()
            Text(title)
                .frame(alignment: .center)
                .fixedSize()
                .font(Font.appDefault(size: Self.isCompactLayout ? 16 : 22, weight: .medium))
                .lineLimit(1)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .aspectRatio(1, contentMode: .fit)
                .padding(Self.isCompactLayout ? 14 : 16)
        }
        .frame(minWidth: 100, maxWidth: .infinity)
        .frame(height: Self.isCompactLayout ? 44 : 56)
        .foregroundColor(.white)
        .background(Color.microsoftBlue)
        .cornerRadius(Self.isCompactLayout ? 16 : 20)
        .overlay(
            RoundedRectangle(cornerRadius: Self.isCompactLayout ? 16 : 20)
                .stroke(Color.microsoftBlue, lineWidth: 2)
        )
    }

}

extension LoginWithMicrosoftButton {
    static var isCompactLayout: Bool {
        UIScreen.main.bounds.width <= 375
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
