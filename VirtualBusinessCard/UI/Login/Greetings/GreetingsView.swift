//
//  GreetingsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 27/02/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct GreetingsView: View {
    
    @ObservedObject var viewModel = GreetingsViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            Image(viewModel.appLogoName)
                .resizable()
                .scaledToFit()
                .frame(height: 30)
            Text(viewModel.title)
                .fontWeight(.bold)
                .font(.system(size: 24))
                .multilineTextAlignment(.center)
            Text(viewModel.subtitle)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Image(viewModel.mainImageName)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .padding(Edge.Set.horizontal, 30)
                .foregroundColor(Color.appAccent)
            Spacer()
            VStack(spacing: 20) {
                createAccountButton
                OrDivider()
                loginButton
            }
            .padding(Edge.Set.vertical, 20)
        }
        .padding(Edge.Set.vertical, 10)
        .padding(Edge.Set.horizontal, 20)
        .sheet(isPresented: $viewModel.isShowingLogin) {
            LoginView(viewModel: LoginViewModel(isPresented: self.$viewModel.isShowingLogin))
        }
    }
    
    
    var createAccountButton: some View {
        Button(action: viewModel.didTapCreateAccount) {
            Text(viewModel.createAccountButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
        }
        .buttonStyle(LightFilledRoundedButtonStyle())
    }
    
    var loginWithGoogleButton: some View {
        Button(action: viewModel.didTapLoginWithGoogle) {
            HStack {
                Image("GoogleLogo")
                    .interpolation(.high)
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .leading)
                    .padding(Edge.Set.horizontal, 10)
                Spacer()
                Text(viewModel.loginWithGoogleButtonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                Spacer()
                Spacer()
                    .frame(width: 40, height: 40, alignment: .leading)
                    .padding(Edge.Set.horizontal, 10)
            }
            .frame(minWidth: 100, maxWidth: .infinity)
        }
        .buttonStyle(BorderedRoundedButtonStyle())
    }
    
    var loginWithAppleButton: some View {
        Button(action: viewModel.didTapLoginWithApple) {
            HStack {
                Image("AppleLogo")
                    .interpolation(.high)
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .leading)
                    .padding(Edge.Set.horizontal, 10)
                Spacer()
                Text(viewModel.loginWithAppleButtonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                Spacer()
                Spacer()
                    .frame(width: 40, height: 40, alignment: .leading)
                    .padding(Edge.Set.horizontal, 10)
            }
            .frame(minWidth: 100, maxWidth: .infinity)
        }
        .buttonStyle(BorderedRoundedButtonStyle())
    }
    
    var loginButton: some View {
        Button(action: viewModel.didTapLogin) {
            Text(viewModel.loginButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
        }
        .buttonStyle(AppDefaultButtonStyle())
    }
}

struct GreetingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GreetingsView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
            
            GreetingsView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }
        //        .environment(\.colorScheme, .dark)
    }
}
