//
//  LoginViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class LoginViewModel: ObservableObject {

    let titleText = NSLocalizedString("How do you want to log in?", comment: "")

    let loginWithGoogleButtonText = NSLocalizedString("Log in with Google", comment: "")
    let loginWithMicrosoftButtonText = NSLocalizedString("Log in with Microsoft", comment: "")
    let loginWithAppleButtonText = NSLocalizedString("Log in with Apple", comment: "")
    let loginWithEmailButtonText = NSLocalizedString("Log in with Email", comment: "")

    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    func didTapLoginWithGoogle() {
        
    }
    
    func didTapLoginWithMicrosoft() {
        
    }
    
    func didTapLoginWithApple() {
        
    }
    
    func didTapLoginWithEmail() {
        
    }
    
    func closeButtonTapped() {
        isPresented = false
    }
}
