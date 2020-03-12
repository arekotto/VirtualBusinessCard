//
//  LoginViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

import Foundation
import Combine

class LoginViewModel: ObservableObject {

    let titleText = NSLocalizedString("Enter your email and password to continue", comment: "")
    
    let emailPlaceholder = NSLocalizedString("Email", comment: "")
    let passwordPlaceholder = NSLocalizedString("Password", comment: "")
    let loginButtonText = NSLocalizedString("Log In", comment: "")

    @Published var email = ""
    @Published var password = ""
    
    func loginButtonTapped() {
        
    }
    
    func closeButtonTapped() {
        
    }
}


