//
//  UserSetupViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class UserSetupViewModel: AppSwiftUIViewModel {
    let text = Text()
    
    let userID: String
    
    @Published var title = ""
    @Published var subtitle = ""
    
    @Published var isAnimatingActivityIndicator = false
    
    var completion: (() -> Void)?
    
    @Published var isErrorAlertPresented = false
    
    init(userID: String) {
        self.userID = userID
        
        title = text.setupInProgressTitle
        subtitle = text.setupInProgressSubtitle
    }
    
    func setupUserInFirebase() {
        InitialUserSetupTask.run(userId: userID) { result in
            // Give the previous alert some time to disappear
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                switch result {
                case .failure(_):
                    self.isErrorAlertPresented = true
                case .success(_):
                    self.title = self.text.setupCompletedTitle
                    self.subtitle = ""
                    self.isAnimatingActivityIndicator = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.completion?()
                    }
                }
            }
        }
    }
}

extension UserSetupViewModel {
    struct Text {
        let setupInProgressTitle = NSLocalizedString("Setting up new account...", comment: "")
        let setupInProgressSubtitle = NSLocalizedString("This should only take a second.", comment: "")
        
        let setupCompletedTitle = NSLocalizedString("Account Setup Finished!", comment: "")

        let errorTitle = NSLocalizedString("Account Setup Couldn't Be Completed", comment: "")

        let errorMessage = NSLocalizedString("We have encountered some unexpected issues while trying to setup your account. If the issue persists please try again later.", comment: "")
        let retryButton = NSLocalizedString("Try Again", comment: "")
        
        fileprivate init() {}
    }
}
