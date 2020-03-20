//
//  CreateAccountViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 20/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Combine
import SwiftUI
import Firebase
import GoogleSignIn

final class CreateAccountViewModel: AppViewModel {

    let text = Text()
    
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
}

extension CreateAccountViewModel {
    enum Navigation  {
        case loginWithEmail
        
        func destination() -> some View {
            switch self {
            case .loginWithEmail: return LoginWithEmailView(viewModel: LoginWithEmailViewModel())
            }
        }
    }
}

extension CreateAccountViewModel {
    struct Text {
        let title = NSLocalizedString("How do you want to join?", comment: "")
        let continueWithGoogleButton = NSLocalizedString("Continue with Google", comment: "")
        let continueWithMicrosoftButton = NSLocalizedString("Continue with Microsoft", comment: "")
        let continueWithAppleButton = NSLocalizedString("Continue with Apple", comment: "")
        let continueWithEmailButton = NSLocalizedString("Join with Email", comment: "")
        
        fileprivate init() {}
    }
}
