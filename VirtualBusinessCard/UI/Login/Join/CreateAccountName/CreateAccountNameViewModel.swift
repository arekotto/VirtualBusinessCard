//
//  CreateAccountNameViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 14/05/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Combine
import SwiftUI

class CreateAccountNameViewModel: AppSwiftUIViewModel {
    
    let text = Text()
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Binding var isPresented: Bool
    
    @Published var navSelection: Navigation?

    var continueButtonDisabled: Bool {
        firstName.isEmpty || lastName.isEmpty
    }
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    func continueButtonTapped() {
        guard !continueButtonDisabled else { return }
        navSelection = .createAccountEmailPassword
    }
    
    func closeButtonTapped() {
        isPresented = false
    }
    
    func createAccountEmailPasswordViewModel() -> CreateAccountEmailPasswordViewModel {
        let namesInfo = CreateAccountEmailPasswordViewModel.UserNamesInfo(firstName: firstName, lastName: lastName)
        return CreateAccountEmailPasswordViewModel(isPresented: $isPresented, namesInfo: namesInfo)
    }
}

extension CreateAccountNameViewModel {
    struct Text {
        let title = NSLocalizedString("Join with Email", comment: "")
        let subtitle = NSLocalizedString("Enter your first and last name.", comment: "")
        let firstNamePlaceholder = NSLocalizedString("First Name", comment: "")
        let lastNamePlaceholder = NSLocalizedString("Last Name", comment: "")
        let continueButton = NSLocalizedString("Continue", comment: "")
        fileprivate init() {}
    }
}

extension CreateAccountNameViewModel {
    enum Navigation {
        case createAccountEmailPassword
    }
}
