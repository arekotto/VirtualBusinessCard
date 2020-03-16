//
//  LoginView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var viewModel: LoginViewModel

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
                Button(action: {
                    self.viewModel.closeButtonTapped()
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        .font(.system(size: 20, weight: .bold))
                        .padding(12)
                }
                .accentColor(Color.accent)
                .background(Color.accent.opacity(0.2))
                .clipShape(Circle())
                //                .background(Color.accent)
            )
        }
    }
    
    var title: some View {
        Text(viewModel.titleText)
            .font(Font.system(size: 24, weight: .semibold, design: .default))
            .multilineTextAlignment(.center)
    }
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView(viewModel: LoginViewModel(isPresented: .constant(false)))
               .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
               .previewDisplayName("iPhone SE")
                    .environment(\.colorScheme, .dark)


            LoginView(viewModel: LoginViewModel(isPresented: .constant(false)))
               .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
               .previewDisplayName("iPhone 11")
        }
    }
}


