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
    static let startingSlideToAcceptStackViewTopConstraint = defaultCardViewSize.height * 1.2

    var startingCardTopConstraintConstant: CGFloat {
        -Self.defaultCardViewSize.height / 2 + statusBarHeight
    }

    private var statusBarHeight: CGFloat {
        window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }

    private(set) var slideToAcceptStackViewTopConstraint: NSLayoutConstraint!
    private(set) lazy var slideToAcceptStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [slideToAcceptLabel, slideToAcceptImageView])
        this.axis = .vertical
        this.distribution = .fillProportionally
        this.spacing = 4
        return this
    }()

    let rejectButton: UIButton = {
        let this = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        this.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
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

    private var statusBarBlurViewHeightConstraint: NSLayoutConstraint!
    private let statusBarBlurView = UIVisualEffectView(effect:  UIBlurEffect(style: .systemUltraThinMaterial))

    override func configureSubviews() {
        super.configureSubviews()
        [slideToAcceptStackView, rejectButton, cardSceneView, statusBarBlurView].forEach { addSubview($0) }
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
        cardSceneViewTopConstraint = cardSceneView.constrainTopToSuperview(inset: 0)

        rejectButton.constrainCenterXToSuperview()
        rejectButton.constrainBottomToSuperviewSafeArea(inset: 20)
        rejectButton.constrainHeight(constant: 50)

        statusBarBlurView.constrainHorizontallyToSuperview()
        statusBarBlurView.constrainTopToSuperview()
        statusBarBlurViewHeightConstraint = statusBarBlurView.constrainHeight(constant: 44)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        statusBarBlurViewHeightConstraint.constant = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        cardSceneViewTopConstraint.constant = startingCardTopConstraintConstant
    }

    override func configureColors() {
        super.configureColors()
        slideToAcceptLabel.textColor = .appGray
        slideToAcceptImageView.tintColor = .appGray
        rejectButton.tintColor = .appAccent
    }
}
