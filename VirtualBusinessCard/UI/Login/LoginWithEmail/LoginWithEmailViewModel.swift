//
//  LoginWithEmailViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI
import Combine
import Firebase

final class LoginWithEmailViewModel: AppViewModel {

    let text = Text()

    @Published var email = ""
    @Published var password = ""
    @Published var isLoginErrorAlertPresented = false
    
    @Binding var isPresented: Bool

    var loginAlertMessage: String {
        previousLoginAlertError?.localizedDescription ?? text.unknownLoginError
    }
    
    var loginButtonDisabled: Bool {
        email.isEmpty || password.isEmpty
    }
    
    private var previousLoginAlertError: Error?
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    func closeButtonTapped() {
        isPresented = false
    }
    
    func loginButtonTapped() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let err = error {
                self.previousLoginAlertError = err
                self.isLoginErrorAlertPresented = true
            }
        }
    }
}

extension LoginWithEmailViewModel {
    struct Text {
        let title = NSLocalizedString("Login with Email", comment: "")
        let emailPlaceholder = NSLocalizedString("Email", comment: "")
        let passwordPlaceholder = NSLocalizedString("Password", comment: "")
        let loginButton = NSLocalizedString("Log In", comment: "")
        let loginAlertTitle = NSLocalizedString("Login Unsuccessful", comment: "")
        let loginAlertDismiss = NSLocalizedString("OK", comment: "")
        
        fileprivate let unknownLoginError = NSLocalizedString("Unknown error has occurred. Please try again.", comment: "")
    }
}


