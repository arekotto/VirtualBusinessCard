//
//  CreateAccountEmailPasswordViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 14/05/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Combine
import SwiftUI
import Firebase

class CreateAccountEmailPasswordViewModel: AppSwiftUIViewModel {
    let text = Text()
    
    let namesInfo: UserNamesInfo

    @Published var email = ""
    @Published var password = ""
    @Binding var isPresented: Bool
    @Published var isErrorAlertPresented = false

    @Published var createAccountErrorMessage = ""
    
    var createAccountButtonDisabled: Bool {
        email.isEmpty || password.isEmpty
    }
        
    init(isPresented: Binding<Bool>, namesInfo: UserNamesInfo) {
        self._isPresented = isPresented
        self.namesInfo = namesInfo
    }
    
    func createAccountButtonTapped() {
        guard !email.isEmpty && !password.isEmpty else { return }
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let err = error {
                print(#file, err.localizedDescription)
                guard let errorCode = AuthErrorCode(rawValue: err._code) else {
                    self.createAccountErrorMessage = AppError.localizedUnknownErrorDescription
                    self.isErrorAlertPresented = true
                    return
                }
                self.createAccountErrorMessage = errorCode.localizedMessageForUser
                self.isErrorAlertPresented = true
            } else {
                SignUpUserInfoStorage.shared.storeInfo(firstName: self.namesInfo.firstName, lastName: self.namesInfo.lastName)
            }
        }
    }
    
    func dismissAlertButtonTapped() {
        createAccountErrorMessage = ""
    }
    
    func closeButtonTapped() {
        isPresented = false
    }
}

extension CreateAccountEmailPasswordViewModel {
    struct UserNamesInfo {
        let firstName: String
        let lastName: String
    }
}

extension CreateAccountEmailPasswordViewModel {
    struct Text {
        let title = NSLocalizedString("Join with Email", comment: "")
        let subtitle = NSLocalizedString("Enter your email and password you want to use.", comment: "")
        let emailPlaceholder = NSLocalizedString("Email", comment: "")
        let passwordPlaceholder = NSLocalizedString("Password", comment: "")
        let createAccountButton = NSLocalizedString("Join Now", comment: "")
//        static let createAccountErrorTitle = NSLocalizedString("We Have Issues Creating Your Account", comment: "")
        
        let createAccountAlertDismiss = NSLocalizedString("OK", comment: "")
        fileprivate init() {}
        
    }
}
