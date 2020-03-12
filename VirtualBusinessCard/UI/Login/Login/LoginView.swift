//
//  LoginView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                title
                VStack(spacing: 20) {
                    TextField(viewModel.emailPlaceholder, text: $viewModel.email)
                    TextField(viewModel.passwordPlaceholder, text: $viewModel.password)
                }
                .padding(10)
                Button(action: viewModel.loginButtonTapped) {
                    Text(viewModel.loginButtonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                }
                .buttonStyle(StrongFilledRoundedButtonStyle())
                Spacer()
            }
            .padding(10)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: viewModel.closeButtonTapped) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .font(.system(size: 30, weight: .medium))
                }
                .accentColor(Color.accent.opacity(0.2))
                //                .background(Color.accent)
            )
        }
    }
    
    var title: some View {
        Text(viewModel.titleText)
            .font(Font.system(size: 24, weight: .semibold, design: .default))
            .multilineTextAlignment(.center)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
               .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
               .previewDisplayName("iPhone SE")

            LoginView()
               .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
               .previewDisplayName("iPhone 11")
        }
        .environment(\.colorScheme, .dark)
    }
}


