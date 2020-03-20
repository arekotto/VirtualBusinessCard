//
//  GreetingsViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 27/02/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation
import Combine

final class GreetingsViewModel: AppViewModel {
    
    // MARK: Constants
    
    let loginButtonText = NSLocalizedString("Log In", comment: "")
    let createAccountButtonText = NSLocalizedString("Create Account", comment: "")
    let loginWithGoogleButtonText = NSLocalizedString("Continue with Google", comment: "")
    let loginWithAppleButtonText = NSLocalizedString("Continue with Apple", comment: "")
    let title = NSLocalizedString("Welcome to \n Virutal Business Card", comment: "")
    let subtitle = NSLocalizedString("Take your business cards on your iPhone wherever you go and share them with new business connections easier than ever.", comment: "")
    let appLogoName = "AppLogo"
    let mainImageName = "BusinessCard"

    
    
    @Published var isShowingLogin = false
    
    func didTapLogin() {
        isShowingLogin = true
    }
    
    func didTapLoginWithGoogle() {
        print("google")

    }
    
    func didTapLoginWithApple() {
        print("apple")

    }
    
    func didTapCreateAccount() {
        print("create")
    }
}

extension GreetingsViewModel {
    struct Const {
        
    }
}
