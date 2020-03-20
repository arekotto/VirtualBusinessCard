//
//  LoginViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Combine
import SwiftUI
import Firebase
import GoogleSignIn

final class LoginViewModel: AppViewModel {

    let titleText = NSLocalizedString("How do you want to log in?", comment: "")

    let loginWithGoogleButtonText = NSLocalizedString("Log in with Google", comment: "")
    let loginWithMicrosoftButtonText = NSLocalizedString("Log in with Microsoft", comment: "")
    let loginWithAppleButtonText = NSLocalizedString("Log in with Apple", comment: "")
    let loginWithEmailButtonText = NSLocalizedString("Log in with Email", comment: "")

    @Binding var isPresented: Bool
    
    @Published var navSelection: Navigation?

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    func didTapLoginWithGoogle() {
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        GIDSignIn.sharedInstance().signIn()
    }
    
    func didTapLoginWithMicrosoft() {
        
    }
    
    func didTapLoginWithApple() {
        
    }
    
    func didTapLoginWithEmail() {
        navSelection = .loginWithEmail
    }
    
    func closeButtonTapped() {
        isPresented = false
    }
    
    func loginWithEmailViewModel() -> LoginWithEmailViewModel {
        LoginWithEmailViewModel()
    }
    
    enum Navigation  {
        case loginWithEmail
    }
}
