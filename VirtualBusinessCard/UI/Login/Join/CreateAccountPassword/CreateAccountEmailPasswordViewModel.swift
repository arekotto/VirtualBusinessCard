//
//  CreateAccountEmailPasswordViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 14/05/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Combine
import SwiftUI

class CreateAccountEmailPasswordViewModel: AppViewModel {
    let text = Text()
    
    let namesInfo: UserNamesInfo

    @Published var email = ""
    @Published var password = ""
    @Binding var isPresented: Bool
    
    var createAccountButtonDisabled: Bool {
        email.isEmpty || password.isEmpty
    }
        
    init(isPresented: Binding<Bool>, namesInfo: UserNamesInfo) {
        self._isPresented = isPresented
        self.namesInfo = namesInfo
    }
    
    func createAccountButtonTapped() {
        
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
        fileprivate init() {}
    }
}
