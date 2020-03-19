//
//  LoginView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var viewModel: LoginViewModel
    
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
                    loginButton
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
    
    var loginButton: some View {
        Button(action: viewModel.didTapLoginWithEmail) {
            Text(viewModel.loginWithEmailButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
        }
        .buttonStyle(AppDefaultButtonStyle())
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
                .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
                .previewDisplayName("iPhone Xs")
                .environment(\.colorScheme, .dark)
            
            LoginView(viewModel: LoginViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }
        
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
