//
//  EditCardVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 31/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

protocol EditCardVMDelegate: class {

}

final class EditCardVM: PartialUserViewModel {

    let title: String

    weak var delegate: EditCardVMDelegate?

    override init(userID: UserID) {
        title = NSLocalizedString("Choose Images", comment: "")
        super.init(userID: userID)
    }
}

extension EditCardVM {
    var nextButtonTitle: String {
        NSLocalizedString("Next", comment: "")
    }

    var cancelEditingButtonTitle: String {
        NSLocalizedString("Cancel", comment: "")
    }
}
