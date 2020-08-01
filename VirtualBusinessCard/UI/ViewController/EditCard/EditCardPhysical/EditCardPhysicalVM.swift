//
//  EditCardPhysicalVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol EditCardPhysicalVMDelegate: class {

}

final class EditCardPhysicalVM: PartialUserViewModel {


    weak var delegate: EditCardPhysicalVMDelegate?

    let images: (cardFront: UIImage, cardBack: UIImage)

    init(userID: UserID, frontCardImage: UIImage, backCardImage: UIImage) {
        images = (frontCardImage, backCardImage)
        super.init(userID: userID)
    }

}
