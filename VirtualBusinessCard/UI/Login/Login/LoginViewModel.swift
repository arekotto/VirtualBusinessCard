//
//  LoginViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class LoginViewModel: ObservableObject {

    let titleText = NSLocalizedString("Enter your email and password to continue", comment: "")
    
    let emailPlaceholder = NSLocalizedString("Email", comment: "")
    let passwordPlaceholder = NSLocalizedString("Password", comment: "")
    let loginButtonText = NSLocalizedString("Log In", comment: "")

    @Binding var isPresented: Bool

    @Published var email = ""
    @Published var password = ""
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    func loginButtonTapped() {
        
    }
    
    func closeButtonTapped() {
        isPresented = false
    }
}


