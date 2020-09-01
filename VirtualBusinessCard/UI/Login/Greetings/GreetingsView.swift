//
//  GreetingsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 27/02/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct GreetingsView: AppSwiftUIView {
    typealias ViewModel = GreetingsViewModel
    
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            Image(viewModel.appLogoName)
                .resizable()
                .scaledToFit()
                .frame(height: 30)
            Text(viewModel.text.title)
                .fontWeight(.bold)
                .font(.system(size: 24))
                .multilineTextAlignment(.center)
            Text(viewModel.text.subtitle)
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
        .sheet(item: $viewModel.presentedSheet) {
            self.destinationView(target: $0)
        }
    }
    
    var createAccountButton: some View {
        Button(action: viewModel.didTapCreateAccount) {
            Text(viewModel.text.createAccountButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
        }
        .buttonStyle(LightFilledRoundedButtonStyle())
    }
    
    var loginButton: some View {
        Button(action: viewModel.didTapLogin) {
            Text(viewModel.text.loginButtonText)
//                .frame(maxWidth: .infinity)
                .frame(height: 54)
        }
        .buttonStyle(AppDefaultButtonStyle())
    }
    
    func destinationView(target: ViewModel.Navigation) -> some View {
        switch target {
        case .login:
            let vm = viewModel.loginViewModel()
            return AnyView(LoginWithEmailView(viewModel: vm))
        case .createAccount:
            let vm = viewModel.createAccountViewModel()
            return AnyView(CreateAccountNameView(viewModel: vm))
        }
    }
}

extension GreetingsView {

}

struct GreetingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GreetingsView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
//                .environment(\.colorScheme, .dark)
            
            GreetingsView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }
    }
}
