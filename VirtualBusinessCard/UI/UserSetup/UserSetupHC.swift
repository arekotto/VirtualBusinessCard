//
//  UserSetupHC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 02/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

class UserSetupHC: UIHostingController<UserSetupView> {
    
    init(userID: UserID, email: String) {
        super.init(rootView: UserSetupView(viewModel: UserSetupViewModel(userID: userID, email: email)))
        rootView.viewModel.completion = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
