//
//  EditCardVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 31/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol EditCardVMDelegate: class {
    func didUpdateNextButtonEnabled()
}

final class EditCardVM: PartialUserViewModel {

    let title: String

    weak var delegate: EditCardVMDelegate?

    var frontImage: UIImage? {
        didSet { didSetNewImage() }
    }

    var backImage: UIImage? {
        didSet { didSetNewImage() }
    }

    override init(userID: UserID) {
        title = NSLocalizedString("Select Images", comment: "")
        super.init(userID: userID)
    }

    private func didSetNewImage() {
        delegate?.didUpdateNextButtonEnabled()
    }
}

extension EditCardVM {

    var nextButtonTitle: String {
        NSLocalizedString("Next", comment: "")
    }

    var cancelEditingButtonTitle: String {
        NSLocalizedString("Cancel", comment: "")
    }

    var nextButtonEnabled: Bool {
        frontImage != nil && backImage != nil
    }

    func editCardPhysicalViewModel() -> EditCardPhysicalVM? {
        guard let frontImage = self.frontImage, let backImage = self.backImage else {
            return nil
        }
        return EditCardPhysicalVM(userID: userID, frontCardImage: frontImage, backCardImage: backImage)
    }
}
