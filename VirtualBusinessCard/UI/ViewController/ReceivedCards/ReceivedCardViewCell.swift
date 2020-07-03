//
//  ReceivedBusinessCardViewCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 15/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CoreMotion

extension ReceivedCardsView {
    final class CollectionCell: AppCollectionViewCell, Reusable {
        
        let cardFrontBackView = CardFrontBackView()
        
        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(cardFrontBackView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            cardFrontBackView.constrainToEdgesOfSuperview()
        }
    }
}
