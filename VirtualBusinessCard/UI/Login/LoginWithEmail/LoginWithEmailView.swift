//
//  LoginWithEmailView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct LoginWithEmailView: AppSwiftUIView {
    typealias ViewModel = LoginWithEmailViewModel
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        NavigationView {
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
            .navigationBarItems(trailing: closeButton)
            .background(NavigationConfigurator { nc in
                nc.navigationBar.standardAppearance.configureWithTransparentBackground()
            })
            .alert(isPresented: $viewModel.isLoginErrorAlertPresented) {
                Alert(title: Text(viewModel.text.loginAlertTitle), message: Text(viewModel.loginAlertMessage), dismissButton: .default(Text(viewModel.text.loginAlertDismiss)))
            }
        }
        .accentColor(Color.appAccent)
    }
    
    var title: some View {
        Text(viewModel.text.title)
            .fontWeight(.bold)
            .font(.system(size: 24))
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
    
    var closeButton: some View {
        Button(action: viewModel.closeButtonTapped) {
            Image(systemName: "xmark")
                .imageScale(.medium)
                .font(.system(size: 20, weight: .bold))
                .padding(12)
        }
        .background(Color.appAccent.opacity(0.1))
        .clipShape(Circle())
    }
    
    init(viewModel: LoginWithEmailViewModel) {
        self.viewModel = viewModel
    }
}
// swiftlint:disable identifier_name
struct LoginTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 18))
            .padding(14)
            .background(Color.appGray.opacity(0.1))
    }
}
// swiftlint:enable identifier_name

struct LoginWithEmailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginWithEmailView(viewModel: LoginWithEmailViewModel(isPresented: .constant(true)))
               .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
               .previewDisplayName("iPhone SE")
                    .environment(\.colorScheme, .dark)

            LoginWithEmailView(viewModel: LoginWithEmailViewModel(isPresented: .constant(true)))
               .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
               .previewDisplayName("iPhone 11")
        }
    }
}
