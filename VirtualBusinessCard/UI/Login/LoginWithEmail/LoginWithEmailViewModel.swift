//
//  LoginWithEmailViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class LoginWithEmailViewModel: ObservableObject {

    let titleText = NSLocalizedString("Enter your email and password to continue", comment: "")
    
    let emailPlaceholder = NSLocalizedString("Email", comment: "")
    let passwordPlaceholder = NSLocalizedString("Password", comment: "")
    let loginButtonText = NSLocalizedString("Log In", comment: "")

    @Published var email = ""
    @Published var password = ""
    
    var loginButtonDisabled: Bool {
        email.isEmpty || password.isEmpty
    }
    
    func loginButtonTapped() {
        
    }
    

}


