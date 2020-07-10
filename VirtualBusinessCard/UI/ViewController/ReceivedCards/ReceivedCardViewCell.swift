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
        static let defaultHeight: CGFloat = 270
        static let defaultWidthMultiplier: CGFloat = 0.85
        static let defaultHeightMultiplier: CGFloat = 0.8

        let cardFrontBackView = CardFrontBackView()
        
        override func configureCell() {
            super.configureCell()
            clipsToBounds = true
        }
        
        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(cardFrontBackView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            cardFrontBackView.constrainCenterToSuperview()
            cardFrontBackView.constrainWidthEqualTo(contentView, multiplier: Self.defaultWidthMultiplier)
            cardFrontBackView.constrainHeightEqualTo(contentView, multiplier: Self.defaultHeightMultiplier)
        }
    }
}