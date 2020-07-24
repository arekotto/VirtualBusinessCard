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
    static let startingSlideToAcceptStackViewTopConstraint = defaultCardViewSize.height * 1.3
    static let cardViewExpandedSize = defaultCardViewSize.height * 2 + 32
    static let cardViewExpandedTopConstraint: CGFloat = 80

    var startingCardTopConstraintConstant: CGFloat {
        -Self.defaultCardViewSize.height / 2
    }

    private(set) var slideToAcceptStackViewTopConstraint: NSLayoutConstraint!
    private(set) lazy var slideToAcceptStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [slideToAcceptLabel, slideToAcceptImageView])
        this.axis = .vertical
        this.distribution = .fillProportionally
        this.spacing = 4
        return this
    }()

    private(set) var cardSceneViewTopConstraint: NSLayoutConstraint!
    private(set) var cardSceneViewHeightConstraint: NSLayoutConstraint!
    private(set) var cardSceneViewWidthConstraint: NSLayoutConstraint!

    let cardSceneView: CardFrontBackView = {
        let this = CardFrontBackView(subScenesHeightMultiplayer: 1)
        this.transform = CGAffineTransform(rotationAngle: .pi/4)
        this.sceneShadowOpacity = 0.2
        return this
    }()

    let rejectButton: UIButton = {
        let this = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        this.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        return this
    }()

    let doneButton: UIButton = {
        let this = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        this.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        return this
    }()

    let doneButtonView: UIView = {
        let this = UIView()
        this.clipsToBounds = true
        this.isHidden = true
        this.alpha = 0
        this.layer.cornerRadius = 22
        return this
    }()

    let cardSavedLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("Saved to collection.", comment: "")
        this.alpha = 0
        this.isHidden = true
        this.font = .appDefault(size: 14, weight: .medium, design: .rounded)
        return this
    }()

    private let doneButtonBackground = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

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

    private let tagsLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("Tags", comment: "")
        this.font = .appDefault(size: 18, weight: .medium, design: .default)
        return this
    }()

    private let scrollView: UIScrollView = {
        let this = UIScrollView()
        this.clipsToBounds = true
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        [doneButtonBackground, doneButton].forEach { doneButtonView.addSubview($0) }
        [slideToAcceptStackView, scrollView, rejectButton, cardSceneView, doneButtonView].forEach { addSubview($0) }
        cardSceneView.addSubview(cardSavedLabel)
    }

    override func configureConstraints() {
        super.configureConstraints()

        let cardSize = Self.defaultCardViewSize
        cardSceneViewWidthConstraint = cardSceneView.constrainWidth(constant: cardSize.width)
        cardSceneViewHeightConstraint = cardSceneView.constrainHeight(constant: cardSize.height)
        cardSceneViewTopConstraint = cardSceneView.constrainTopToSuperviewSafeArea()
        cardSceneView.constrainCenterXToSuperview()

        scrollView.constrainToSuperview()

        cardSavedLabel.constrainCenterXToSuperview()
        cardSavedLabel.constrainTop(to: cardSceneView.bottomAnchor, constant: 30)

        slideToAcceptStackView.constrainCenterXToSuperview()
        slideToAcceptStackViewTopConstraint = slideToAcceptStackView.constrainTopToSuperview(inset: Self.startingSlideToAcceptStackViewTopConstraint)
        slideToAcceptImageView.constrainHeight(constant: 30)

        rejectButton.constrainCenterXToSuperview()
        rejectButton.constrainBottomToSuperviewSafeArea(inset: 20)
        rejectButton.constrainHeight(constant: 50)

        doneButton.constrainToEdgesOfSuperview()
        doneButtonBackground.constrainToEdgesOfSuperview()
        doneButtonView.constrainTopToSuperview(inset: 16)
        doneButtonView.constrainTrailingToSuperview(inset: 16)
        doneButtonView.constrainHeight(constant: 44)
        doneButtonView.constrainWidth(constant: 44)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        cardSceneViewTopConstraint.constant = startingCardTopConstraintConstant
    }

    override func configureColors() {
        super.configureColors()
        slideToAcceptLabel.textColor = .appGray
        slideToAcceptImageView.tintColor = .appGray
        rejectButton.tintColor = .appAccent
        doneButton.backgroundColor = UIColor.appGray.withAlphaComponent(0.1)
        doneButton.tintColor = .appAccent
        cardSavedLabel.textColor = .tertiaryLabel
    }

    func prepareForExpandedCardView() {
        cardSceneView.removeFromSuperview()

        scrollView.addSubview(cardSceneView)
        scrollView.alwaysBounceVertical = true

        cardSceneViewTopConstraint = cardSceneView.constrainTopToSuperview(inset: Self.cardViewExpandedTopConstraint)
        cardSceneView.constrainBottom(to: scrollView.bottomAnchor)
        cardSceneView.constrainCenterXToSuperview()
        cardSceneView.setDynamicLightingEnabled(true)
    }
}
