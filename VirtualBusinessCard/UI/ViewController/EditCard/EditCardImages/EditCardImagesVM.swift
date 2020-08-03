//
//  EditCardImagesVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 31/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol EditCardVMDelegate: class {
    func didUpdateNextButtonEnabled()
}

final class EditCardImagesVM: PartialUserViewModel {

    weak var delegate: EditCardVMDelegate?

    var frontImage: UIImage? {
        didSet { didSetNewImage() }
    }

    var backImage: UIImage? {
        didSet { didSetNewImage() }
    }

    init(userID: UserID, frontImage: UIImage? = nil, backImage: UIImage? = nil) {
        super.init(userID: userID)
        self.frontImage = frontImage
        self.backImage = backImage
    }

    private func didSetNewImage() {
        delegate?.didUpdateNextButtonEnabled()
    }
}

extension EditCardImagesVM {

    var title: String {
        NSLocalizedString("Card Images", comment: "")
    }

    var nextButtonTitle: String {
        NSLocalizedString("Next", comment: "")
    }

    var cancelEditingButtonTitle: String {
        NSLocalizedString("Cancel", comment: "")
    }

    var nextButtonEnabled: Bool {
        frontImage != nil && backImage != nil
    }
}
