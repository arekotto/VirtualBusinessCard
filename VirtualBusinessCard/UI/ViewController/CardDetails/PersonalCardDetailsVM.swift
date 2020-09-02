//
//  PersonalCardDetailsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/09/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import UIKit
import CoreMotion

final class PersonalCardDetailsVM: CardDetailsVM {

    var card: BusinessCardLocalization?

    override var cardLocalization: BusinessCardLocalization? {
        card
    }

    override func fetchData() {
        makeSections()
    }

    override func sectionFactory() -> CardDetailsSectionFactory? {
        guard let card = self.card else { return nil }
        return PersonalCardDetailsSectionFactory(card: card, imageProvider: Self.iconImage)
    }
}
