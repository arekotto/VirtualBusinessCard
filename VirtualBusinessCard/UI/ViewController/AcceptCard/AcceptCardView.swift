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
    static let cardViewExpandedSize = defaultCardViewSize.height * 2 + 16

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

    let rejectButton: UIButton = {
        let this = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        this.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        return this
    }()

    let doneButton: UIButton = {
        let this = UIButton()
        this.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        this.titleLabel?.font = .appDefault(size: 18, weight: .medium, design: .rounded)
        this.isHidden = true
        this.alpha = 0
        this.clipsToBounds = true
        this.layer.cornerRadius = 12
        this.contentEdgeInsets = UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
        return this
    }()

    private(set) var cardSceneViewTopConstraint: NSLayoutConstraint!
    private(set) var cardSceneViewHeightConstraint: NSLayoutConstraint!
    private(set) var cardSceneViewWidthConstraint: NSLayoutConstraint!
    let cardSceneView: CardFrontBackView = {
        let this = CardFrontBackView(subScenesHeightMultiplayer: 1)
        this.setDynamicLightingEnabled(false)
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

    private let tagsLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("Tags", comment: "")
        this.font = .appDefault(size: 18, weight: .medium, design: .default)
        return this
    }()

    private let imageViews: [UIImageView] = {
        Array(0..<3).map { _ in
            let this = UIImageView()
            this.contentMode = .scaleAspectFit
            return this
        }
    }()

    private lazy var tagStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [tagsLabel] + imageViews)
        return this
    }()

    private(set) lazy var mainStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [tagStackView])
        this.isHidden = true
        this.alpha = 0
        this.axis = .vertical
        return this
    }()

    private var statusBarBlurViewHeightConstraint: NSLayoutConstraint!
    let statusBarBlurView = UIVisualEffectView(effect:  UIBlurEffect(style: .systemUltraThinMaterial))

    override func configureSubviews() {
        super.configureSubviews()
        [slideToAcceptStackView, rejectButton, doneButton, cardSceneView, statusBarBlurView, mainStackView].forEach { addSubview($0) }
    }

    override func configureConstraints() {
        super.configureConstraints()

        let cardSize = Self.defaultCardViewSize
        cardSceneViewWidthConstraint = cardSceneView.constrainWidth(constant: cardSize.width)
        cardSceneViewHeightConstraint = cardSceneView.constrainHeight(constant: cardSize.height)
        cardSceneViewTopConstraint = cardSceneView.constrainTopToSuperviewSafeArea(inset: 0)
        cardSceneView.constrainCenterXToSuperview()

        slideToAcceptStackView.constrainCenterXToSuperview()
        slideToAcceptStackViewTopConstraint = slideToAcceptStackView.constrainTopToSuperview(inset: Self.startingSlideToAcceptStackViewTopConstraint)
        slideToAcceptImageView.constrainHeight(constant: 30)

        rejectButton.constrainCenterXToSuperview()
        rejectButton.constrainBottomToSuperviewSafeArea(inset: 20)
        rejectButton.constrainHeight(constant: 50)

        doneButton.constrainCenterXToSuperview()
        doneButton.constrainBottomToSuperviewSafeArea(inset: 20)
        doneButton.constrainHeight(constant: 50)

        mainStackView.constrainHorizontallyToSuperview(sideInset: 16)
        mainStackView.constrainTop(to: cardSceneView.bottomAnchor, constant: 16)

        statusBarBlurView.constrainHorizontallyToSuperview()
        statusBarBlurView.constrainTopToSuperview()
        statusBarBlurViewHeightConstraint = statusBarBlurView.constrainHeight(constant: 44)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        statusBarBlurViewHeightConstraint.constant = statusBarHeight ?? 0
        cardSceneViewTopConstraint.constant = startingCardTopConstraintConstant
    }

    override func configureColors() {
        super.configureColors()
        slideToAcceptLabel.textColor = .appGray
        slideToAcceptImageView.tintColor = .appGray
        rejectButton.tintColor = .appAccent
        doneButton.backgroundColor = UIColor.appGray.withAlphaComponent(0.1)
        doneButton.setTitleColor(.appAccent, for: .normal)
    }
}
