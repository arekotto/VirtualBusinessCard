//
//  CreateAccountNameView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 14/05/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct CreateAccountNameView: AppSwiftUIView {
    typealias ViewModel = CreateAccountNameViewModel
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            NavigationLink(
                destination: CreateAccountEmailPasswordView(viewModel: viewModel.createAccountEmailPasswordViewModel()),
                tag: .createAccountEmailPassword,
                selection: $viewModel.navSelection) {
                EmptyView()
            }
            bodyContent
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: closeButton)
    }
    
    var bodyContent: some View {
        VStack(spacing: 10) {
            title
            subtitle
            textFields
            continueButton
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
    
    var textFields: some View {
        VStack(spacing: 2) {
            TextField(viewModel.text.firstNamePlaceholder, text: $viewModel.firstName)
                .textFieldStyle(LoginTextFieldStyle())
                .textContentType(.name)
                .keyboardType(.default)
                .autocapitalization(.words)
            TextField(viewModel.text.lastNamePlaceholder, text: $viewModel.lastName)
                .textFieldStyle(LoginTextFieldStyle())
                .textContentType(.familyName)
                .keyboardType(.default)
                .autocapitalization(.words)
        }
        .cornerRadius(20)
    }
    
    var continueButton: some View {
        Button(action: viewModel.continueButtonTapped) {
            Text(viewModel.text.continueButton)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
        }
        .buttonStyle(LightFilledRoundedButtonStyle(disabled: viewModel.continueButtonDisabled))
        .disabled(viewModel.continueButtonDisabled)
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
}

struct CreateAccountNameView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateAccountNameView(viewModel: CreateAccountNameViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .dark)
            
            CreateAccountNameView(viewModel: CreateAccountNameViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
            
            CreateAccountNameView(viewModel: CreateAccountNameViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
                .previewDisplayName("iPhone Xs")
                .environment(\.colorScheme, .dark)
            
            CreateAccountNameView(viewModel: CreateAccountNameViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }
    }
}
