//
//  AcceptCardView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class AcceptCardView: AppBackgroundView {

    static let defaultCardViewSize = CGSize.businessCardSize(width: UIScreen.main.bounds.width * 0.8)
    static let startingCardTopConstraintConstant = -defaultCardViewSize.height / 2
    static let startingSlideToAcceptStackViewTopConstraint = defaultCardViewSize.height * 1.2

    private(set) var slideToAcceptStackViewTopConstraint: NSLayoutConstraint!
    private(set) lazy var slideToAcceptStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [slideToAcceptLabel, slideToAcceptImageView])
        this.axis = .vertical
        this.distribution = .fillProportionally
        this.spacing = 4
        return this
    }()


    private(set) var cardSceneViewTopConstraint: NSLayoutConstraint!
    let cardSceneView: BusinessCardSceneView = {
        let this = BusinessCardSceneView()
        this.dynamicLightingEnabled = false
        this.transform = CGAffineTransform(rotationAngle: .pi/4)
        this.layer.shadowRadius = 9
        this.layer.shadowOpacity = 0.35
        return this
    }()

    private let slideToAcceptLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("Slide to Accept", comment: "")
        this.font = .appDefault(size: 20, weight: .semibold, design: .rounded)
        return this
    }()

    private let slideToAcceptImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let this = UIImageView(image: UIImage(systemName: "arrow.down", withConfiguration: config))
        this.contentMode = .scaleAspectFit
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        [slideToAcceptStackView, cardSceneView].forEach { addSubview($0) }
    }

    override func configureConstraints() {
        super.configureConstraints()

        let cardSize = Self.defaultCardViewSize
        cardSceneView.constrainWidth(constant: cardSize.width)
        cardSceneView.constrainHeight(constant: cardSize.height)

        slideToAcceptStackView.constrainCenterXToSuperview()
        slideToAcceptStackViewTopConstraint = slideToAcceptStackView.constrainTopToSuperview(inset: Self.startingSlideToAcceptStackViewTopConstraint)
        slideToAcceptImageView.constrainHeight(constant: 30)

        cardSceneView.constrainCenterXToSuperview()
        cardSceneViewTopConstraint = cardSceneView.constrainTopToSuperview(inset: Self.startingCardTopConstraintConstant)
    }

    override func configureColors() {
        super.configureColors()
        slideToAcceptLabel.textColor = .appGray
        slideToAcceptImageView.tintColor = .appGray

    }
}
