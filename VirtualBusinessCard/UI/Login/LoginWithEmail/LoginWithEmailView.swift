//
//  LoginWithEmailView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct LoginWithEmailView: View {
    
    @ObservedObject var viewModel: LoginWithEmailViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                title
                textFields
                Button(action: viewModel.loginButtonTapped) {
                    Text(viewModel.loginButtonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                }
                .buttonStyle(LightFilledRoundedButtonStyle(disabled: viewModel.loginButtonDisabled))
                .disabled(viewModel.loginButtonDisabled)
                Spacer()
            }
            .padding(10)
            .navigationBarTitle("", displayMode: .inline)
            
        }
    }
    
    var title: some View {
        Text(viewModel.titleText)
            .font(Font.appDefault(size: 24, weight: .semibold, design: .default))
            .multilineTextAlignment(.center)
    }
    
    var textFields: some View {
        VStack(spacing: 2) {
            TextField(viewModel.emailPlaceholder, text: $viewModel.email)
                .textFieldStyle(LoginTextFieldStyle())
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
            SecureField(viewModel.passwordPlaceholder, text: $viewModel.password)
                .textFieldStyle(LoginTextFieldStyle())
                .textContentType(.password)
        }
        .cornerRadius(20)
    }
    
    init(viewModel: LoginWithEmailViewModel) {
        self.viewModel = viewModel
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    struct LoginTextFieldStyle : TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .font(.system(size: 18))
                .padding(14)
                .background(Color.appGray.opacity(0.1))
        }
    }
}

struct LoginWithEmailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginWithEmailView(viewModel: LoginWithEmailViewModel())
               .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
               .previewDisplayName("iPhone SE")
                    .environment(\.colorScheme, .dark)


            LoginWithEmailView(viewModel: LoginWithEmailViewModel())
               .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
               .previewDisplayName("iPhone 11")
        }
    }
}


