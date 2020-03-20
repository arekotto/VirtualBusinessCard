//
//  LoginView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct LoginView: AppView {
    typealias ViewModel = LoginViewModel
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Text(viewModel.titleText)
                    .fontWeight(.bold)
                    .font(.system(size: 24))
                    .multilineTextAlignment(.center)
                Spacer()
                Spacer()
                VStack(spacing: 20) {
                    loginWithMicrosoftButton
                    loginWithGoogleButton
                    loginWithAppleButton
                    OrDivider()
                    loginWithEmailButton
                }
                .padding(Edge.Set.vertical, 20)
            }
            .padding(Edge.Set.vertical, 10)
            .padding(Edge.Set.horizontal, 20)
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
                .background(Color.appAccent.opacity(0.1))
                .clipShape(Circle())
            )
        }
        .accentColor(Color.appAccent)
    }
    
    var loginWithGoogleButton: some View {
        Button(action: viewModel.didTapLoginWithGoogle) {
            LoginWithGoogleButton(title: viewModel.loginWithGoogleButtonText)
        }
        .buttonStyle(ShrinkOnTapButtonStyle())
    }
    
    var loginWithMicrosoftButton: some View {
        Button(action: viewModel.didTapLoginWithMicrosoft) {
            LoginWithMicrosoftButton(title: viewModel.loginWithMicrosoftButtonText)
        }
        .buttonStyle(ShrinkOnTapButtonStyle())
    }
    
    var loginWithAppleButton: some View {
        Button(action: viewModel.didTapLoginWithApple) {
            LoginWithAppleButton(title: viewModel.loginWithAppleButtonText)
        }
        .buttonStyle(ShrinkOnTapButtonStyle())
    }
    
    var loginWithEmailButton: some View {
        NavigationLink(destination: ViewModel.Navigation.loginWithEmail.destination(), tag: .loginWithEmail, selection: $viewModel.navSelection) {
            Button(action: viewModel.didTapLoginWithEmail) {
                Text(viewModel.loginWithEmailButtonText)
//                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(AppDefaultButtonStyle())
        }
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
            LoginView(viewModel: LoginViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .dark)
            
            LoginView(viewModel: LoginViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
            
            LoginView(viewModel: LoginViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
                .previewDisplayName("iPhone Xs")
                .environment(\.colorScheme, .dark)
            
            LoginView(viewModel: LoginViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }
        
    }
}
