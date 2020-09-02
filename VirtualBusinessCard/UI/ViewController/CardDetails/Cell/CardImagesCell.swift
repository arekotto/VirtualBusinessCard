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

        private(set) var expandMode = ExpandMode.none

        private var currentDataModel: CardFrontBackView.URLDataModel? {
            didSet {
                guard let dataModel = currentDataModel else { return }
                cardFrontBackView.setDataModel(dataModel)
            }
        }

        private let cardFrontBackView = CardFrontBackView()

        private var cardFrontBackViewHeightConstraint: NSLayoutConstraint!
        private var cardFrontBackViewWidthConstraint: NSLayoutConstraint!

        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(cardFrontBackView)
        }

        override func configureConstraints() {
            super.configureConstraints()
            cardFrontBackView.constrainCenterToSuperview()
            cardFrontBackViewWidthConstraint = cardFrontBackView.constrainWidthEqualTo(
                self,
                multiplier: ReceivedCardsView.CollectionCell.defaultWidthMultiplier
            )
            cardFrontBackViewHeightConstraint = cardFrontBackView.constrainHeightEqualTo(
                self,
                multiplier: ReceivedCardsView.CollectionCell.defaultHeightMultiplier
            )
        }

        func updateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
            cardFrontBackView.updateMotionData(motion, over: timeFrame)
        }
    }
}

extension CardDetailsView.CardImagesCell {
    enum ExpandMode: Equatable {
        case fully, partial, none
    }

    func setExpandMode(_ mode: ExpandMode, animated: Bool, completion: (() -> Void)? = nil) {
        guard expandMode != mode else {
            completion?()
            return
        }
        switch mode {
        case .fully:
            expandFully(animated: animated, completion: completion)
        case .partial:
            expandPartially(animated: animated, useSpring: expandMode == .none, completion: completion)
        case .none:
            condense(animated: animated, completion: completion)
        }
        expandMode = mode
    }

    private func expandFully(animated: Bool, completion: (() -> Void)? = nil) {

        cardFrontBackViewHeightConstraint.isActive = false
        cardFrontBackViewWidthConstraint.isActive = false

        cardFrontBackViewHeightConstraint = cardFrontBackView.constrainHeightEqualTo(self, multiplier: 0.85)
        cardFrontBackViewWidthConstraint = cardFrontBackView.constrainWidth(constant: cardFrontBackView.frontSceneView.frame.width)

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            } completion: { _ in
                completion?()
            }
        } else {
            layoutIfNeeded()
        }
    }

    private func expandPartially(animated: Bool, useSpring: Bool, completion: (() -> Void)? = nil) {

        if !cardFrontBackView.areSceneHeightsLocked {
            cardFrontBackView.lockScenesToCurrentHeights()
        }

        cardFrontBackViewHeightConstraint.isActive = false
        cardFrontBackViewWidthConstraint.isActive = false

        let newWidth = UIScreen.main.bounds.width - 32
        let newOffset = newWidth - self.frame.width * ReceivedCardsView.CollectionCell.defaultWidthMultiplier

        let multi = ReceivedCardsView.CollectionCell.defaultHeightMultiplier

        cardFrontBackViewHeightConstraint = cardFrontBackView.constrainHeightEqualTo(self, constant: newOffset, multiplier: multi)
        cardFrontBackViewWidthConstraint = cardFrontBackView.constrainWidth(constant: newWidth)

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: useSpring ? 0.6 : 1, initialSpringVelocity: 1, options: useSpring ? [.curveEaseOut] : []) {
                self.layoutIfNeeded()
            } completion: { _ in
                completion?()
            }
        } else {
            layoutIfNeeded()
        }
    }

    private func condense(animated: Bool, completion: (() -> Void)?) {

        cardFrontBackViewHeightConstraint.isActive = false
        cardFrontBackViewWidthConstraint.isActive = false

        cardFrontBackViewWidthConstraint = cardFrontBackView.constrainWidthEqualTo(
            self,
            multiplier: ReceivedCardsView.CollectionCell.defaultWidthMultiplier
        )
        cardFrontBackViewHeightConstraint = cardFrontBackView.constrainHeightEqualTo(
            self,
            multiplier: ReceivedCardsView.CollectionCell.defaultHeightMultiplier
        )

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
}
