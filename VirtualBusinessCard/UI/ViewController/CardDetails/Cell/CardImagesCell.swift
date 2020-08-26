//
//  CardImagesCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 26/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CoreMotion

extension CardDetailsView {

    final class CardImagesCell: AppCollectionViewCell, Reusable {

        var dataModel: CardFrontBackView.URLDataModel? {
            get { currentDataModel }
            set {
                guard currentDataModel != newValue else { return }
                currentDataModel = newValue
            }
        }

        private(set) var isExtended = false

        private var currentDataModel: CardFrontBackView.URLDataModel? {
            didSet {
                guard let dataModel = currentDataModel else { return }
                cardFrontBackView.setDataModel(dataModel)
            }
        }

        private let cardFrontBackView = CardFrontBackView()

        private var cardFrontBackViewCompactHeightConstraint: NSLayoutConstraint!
        private var cardFrontBackViewCompactWidthConstraint: NSLayoutConstraint!

        private var cardFrontBackViewExtendedHeightConstraint: NSLayoutConstraint?
        private var cardFrontBackViewExtendedWidthConstraint: NSLayoutConstraint?

        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(cardFrontBackView)
        }

        override func configureConstraints() {
            super.configureConstraints()
            cardFrontBackView.constrainCenterToSuperview()
            cardFrontBackViewCompactWidthConstraint = cardFrontBackView.constrainWidthEqualTo(
                self,
                multiplier: ReceivedCardsView.CollectionCell.defaultWidthMultiplier
            )
            cardFrontBackViewCompactHeightConstraint = cardFrontBackView.constrainHeightEqualTo(
                self,
                multiplier: ReceivedCardsView.CollectionCell.defaultHeightMultiplier
            )
        }

        func extend(animated: Bool, completion: (() -> Void)? = nil) {
            guard !isExtended else { return }
            isExtended = true

            cardFrontBackView.lockScenesToCurrentHeights()

            cardFrontBackViewCompactHeightConstraint.isActive = false
            cardFrontBackViewCompactWidthConstraint.isActive = false

            let newWidth = UIScreen.main.bounds.width - 32
            let newOffset = newWidth - cardFrontBackView.frame.width

            cardFrontBackViewExtendedWidthConstraint = cardFrontBackView.constrainWidth(constant: newWidth)
            let multi = ReceivedCardsView.CollectionCell.defaultHeightMultiplier
            cardFrontBackViewExtendedHeightConstraint = cardFrontBackView.constrainHeightEqualTo(self, constant: newOffset, multiplier: multi)

            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.curveEaseOut]) {
                    self.layoutIfNeeded()
                } completion: { _ in
                    completion?()
                }
            } else {
                layoutIfNeeded()
            }
        }

        func condenseWithAnimation(completion: @escaping () -> Void) {
            guard isExtended else { return }
            isExtended = false

            cardFrontBackViewExtendedWidthConstraint?.isActive = false
            cardFrontBackViewExtendedHeightConstraint?.isActive = false
            cardFrontBackViewCompactHeightConstraint.isActive = true
            cardFrontBackViewCompactWidthConstraint.isActive = true
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.curveEaseOut]) {
                self.layoutIfNeeded()
            } completion: { _ in
                completion()
            }
        }

        func updateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
            cardFrontBackView.updateMotionData(motion, over: timeFrame)
        }
    }
}
