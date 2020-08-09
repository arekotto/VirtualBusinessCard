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

final class EditCardImagesVM: AppViewModel {

    weak var delegate: EditCardVMDelegate?

    private(set) var subtitle: String

    var frontImage: UIImage? {
        didSet { didSetNewImage() }
    }

    var backImage: UIImage? {
        didSet { didSetNewImage() }
    }

    init(subtitle: String, frontImage: UIImage? = nil, backImage: UIImage? = nil) {
        self.subtitle = subtitle
        super.init()
        self.frontImage = frontImage
        self.backImage = backImage
    }

    private func didSetNewImage() {
        delegate?.didUpdateNextButtonEnabled()
    }
}

extension EditCardImagesVM {
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
