//
//  CreateAccountEmailPasswordView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 14/05/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct CreateAccountEmailPasswordView: AppView {
    typealias ViewModel = CreateAccountEmailPasswordViewModel
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        bodyContent
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: closeButton)
    }
    
    var bodyContent: some View {
        VStack(spacing: 10) {
            title
            subtitle
            textFields
            createAccountButton
            Spacer()
        }
        .accentColor(.appAccent)
        .padding(10)
    }
    
    var title: some View {
        Text(viewModel.text.title)
            .fontWeight(.bold)
            .font(.system(size: 24))
            .multilineTextAlignment(.center)
    }
    
    var subtitle: some View {
        Text(viewModel.text.subtitle)
            .font(.system(size: 16))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
    
    var createAccountButton: some View {
        Button(action: viewModel.createAccountButtonTapped) {
            Text(viewModel.text.createAccountButton)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
        }
        .buttonStyle(LightFilledRoundedButtonStyle(disabled: viewModel.createAccountButtonDisabled))
        .disabled(viewModel.createAccountButtonDisabled)
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
}

struct CreateAccountPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateAccountEmailPasswordView(viewModel: CreateAccountEmailPasswordViewModel(isPresented: .constant(true), namesInfo: .init(firstName: "", lastName: "")))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .dark)
            
            CreateAccountEmailPasswordView(viewModel: CreateAccountEmailPasswordViewModel(isPresented: .constant(true), namesInfo: .init(firstName: "", lastName: "")))
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
            
            CreateAccountEmailPasswordView(viewModel: CreateAccountEmailPasswordViewModel(isPresented: .constant(true), namesInfo: .init(firstName: "", lastName: "")))
                .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
                .previewDisplayName("iPhone Xs")
                .environment(\.colorScheme, .dark)
            
            CreateAccountEmailPasswordView(viewModel: CreateAccountEmailPasswordViewModel(isPresented: .constant(true), namesInfo: .init(firstName: "", lastName: "")))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }
    }
}



