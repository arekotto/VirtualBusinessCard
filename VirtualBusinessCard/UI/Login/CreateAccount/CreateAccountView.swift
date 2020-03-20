//
//  CreateAccountView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 20/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct CreateAccountView: AppView {
    typealias ViewModel = CreateAccountViewModel
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Text(viewModel.text.title)
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
            LoginWithGoogleButton(title: viewModel.text.continueWithGoogleButton)
        }
        .buttonStyle(ShrinkOnTapButtonStyle())
    }
    
    var loginWithMicrosoftButton: some View {
        Button(action: viewModel.didTapLoginWithMicrosoft) {
            LoginWithMicrosoftButton(title: viewModel.text.continueWithMicrosoftButton)
        }
        .buttonStyle(ShrinkOnTapButtonStyle())
    }
    
    var loginWithAppleButton: some View {
        Button(action: viewModel.didTapLoginWithApple) {
            LoginWithAppleButton(title: viewModel.text.continueWithAppleButton)
        }
        .buttonStyle(ShrinkOnTapButtonStyle())
    }
    
    var loginWithEmailButton: some View {
        NavigationLink(destination: ViewModel.Navigation.loginWithEmail.destination(), tag: .loginWithEmail, selection: $viewModel.navSelection) {
            Button(action: viewModel.didTapLoginWithEmail) {
                Text(viewModel.text.continueWithEmailButton)
//                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(AppDefaultButtonStyle())
        }
    }
    
    init(viewModel: CreateAccountViewModel) {
        self.viewModel = viewModel
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateAccountView(viewModel: CreateAccountViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .dark)
            
            CreateAccountView(viewModel: CreateAccountViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
            
            CreateAccountView(viewModel: CreateAccountViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
                .previewDisplayName("iPhone Xs")
                .environment(\.colorScheme, .dark)
            
            CreateAccountView(viewModel: CreateAccountViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }
        
    }
}
