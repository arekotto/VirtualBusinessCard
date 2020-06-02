//
//  GreetingsViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 27/02/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class GreetingsViewModel: AppSwiftUIViewModel {
    
    let text = Text()
    let appLogoName = "AppLogo"
    let mainImageName = "BusinessCard"
    
    @Published var presentedSheet: Navigation?
    
    func didTapLogin() {
        presentedSheet = .login
    }

    func didTapCreateAccount() {
        presentedSheet = .createAccount
    }
    
    func loginViewModel() -> LoginViewModel {
        LoginViewModel(isPresented: Binding<Bool>(
            get: { self.presentedSheet != nil },
            set: {
                if !$0 {
                    self.presentedSheet = nil
                }
            }
        ))
    }
    
    func createAccountViewModel() -> CreateAccountViewModel {
        CreateAccountViewModel(isPresented: Binding<Bool>(
            get: { self.presentedSheet != nil },
            set: {
                if !$0 {
                    self.presentedSheet = nil
                }
            }
        ))
    }
}

extension GreetingsViewModel {
    enum Navigation: String, Identifiable {
        case login, createAccount
        
        var id: String { rawValue }
    }
}

extension GreetingsViewModel {
    struct Text {
        let loginButtonText = NSLocalizedString("Log In", comment: "")
        let createAccountButtonText = NSLocalizedString("Create Account", comment: "")
        let loginWithGoogleButtonText = NSLocalizedString("Continue with Google", comment: "")
        let loginWithAppleButtonText = NSLocalizedString("Continue with Apple", comment: "")
        let title = NSLocalizedString("Welcome to \n Virutal Business Card", comment: "")
        let subtitle = NSLocalizedString("Take your business cards on your iPhone wherever you go and share them with new business connections easier than ever.", comment: "")
        
        fileprivate init() {}
    }
}
