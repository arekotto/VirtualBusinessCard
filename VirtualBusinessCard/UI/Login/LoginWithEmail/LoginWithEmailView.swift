//
//  LoginWithEmailView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct LoginWithEmailView: AppView {
    typealias ViewModel = LoginWithEmailViewModel
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
            VStack(spacing: 20) {
                title
                textFields
                Button(action: viewModel.loginButtonTapped) {
                    Text(viewModel.text.loginButton)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                }
                .buttonStyle(LightFilledRoundedButtonStyle(disabled: viewModel.loginButtonDisabled))
                .disabled(viewModel.loginButtonDisabled)
                Spacer()
            }
            .accentColor(.appAccent)
            .padding(10)
            .navigationBarTitle("", displayMode: .inline)
            .alert(isPresented: $viewModel.isLoginErrorAlertPresented) {
                Alert(title: Text(viewModel.text.loginAlertTitle), message: Text(viewModel.loginAlertMessage), dismissButton: .default(Text(viewModel.text.loginAlertDismiss)))
            }
    }
    
    var title: some View {
        Text(viewModel.text.title)
            .font(Font.appDefault(size: 24, weight: .semibold, design: .default))
            .multilineTextAlignment(.center)
    }
    
    var textFields: some View {
        VStack(spacing: 2) {
            TextField(viewModel.text.emailPlaceholder, text: $viewModel.email)
                .textFieldStyle(LoginTextFieldStyle())
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            SecureField(viewModel.text.passwordPlaceholder, text: $viewModel.password)
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


