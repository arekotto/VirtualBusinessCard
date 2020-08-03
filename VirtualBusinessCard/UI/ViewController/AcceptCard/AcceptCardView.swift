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
    static let cardViewExpandedSize = defaultCardViewSize.height * 2 + 24
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
        let this = CardFrontBackView(sceneHeightAdjustMode: .fixed)
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

    let cardSavedLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("Saved to collection.", comment: "")
        this.alpha = 0
        this.isHidden = true
        this.font = .appDefault(size: 14, weight: .medium, design: .rounded)
        return this
    }()

    private let tagsCollectionViewContainer = UIView()
    let tagsCollectionView: CompactTagsCollectionView = {
        let this = CompactTagsCollectionView()
        this.targetWidth = defaultCardViewSize.width
        return this
    }()

    let scrollView: UIScrollView = {
        let this = UIScrollView()
        this.clipsToBounds = false
        return this
    }()

    let notesLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("", comment: "")
        this.font = .appDefault(size: 15, weight: .regular)
        this.textColor = Asset.Colors.secondaryText.color
        this.numberOfLines = 0
        return this
    }()

    private var doneButtonViewTopConstraint: NSLayoutConstraint!
    let doneButtonView: TransparentButtonView = {
        let this = TransparentButtonView(style: .systemMaterial, shapeIntoCircle: false)
        this.button.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        this.button.titleLabel?.lineBreakMode = .byWordWrapping
        this.isHidden = true
        this.alpha = 0
        this.layer.cornerRadius = 16
        this.button.titleLabel?.font = .appDefault(size: 15, weight: .medium, design: .rounded)
        this.button.titleLabel?.textAlignment = .center
        return this
    }()

    private var shareAgainButtonViewTopConstraint: NSLayoutConstraint!
    let shareAgainButtonView: TransparentButtonView = {
        let this = TransparentButtonView(style: .systemMaterial, shapeIntoCircle: false)
        this.button.setTitle(NSLocalizedString("Share Again", comment: ""), for: .normal)
        this.button.titleLabel?.lineBreakMode = .byWordWrapping
        this.isHidden = true
        this.alpha = 0
        this.layer.cornerRadius = 16
        this.button.titleLabel?.font = .appDefault(size: 15, weight: .medium, design: .rounded)
        this.button.titleLabel?.textAlignment = .center
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

    private let tagsTitleLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("Tags", comment: "")
        this.font = .appDefault(size: 22, weight: .semibold)
        return this
    }()

    private let notesTitleLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("Notes", comment: "")
        this.font = .appDefault(size: 22, weight: .semibold)
        return this
    }()

    private(set) lazy var tagStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [tagsTitleLabel, tagsCollectionViewContainer])
        this.axis = .vertical
        this.spacing = 4
        this.isHidden = true
        return this
    }()

    private(set) lazy var notesStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [notesTitleLabel, notesLabel])
        this.axis = .vertical
        this.spacing = 4
        this.isHidden = true
        return this
    }()

    private lazy var mainStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [tagStackView, notesStackView])
        this.axis = .vertical
        this.spacing = 20
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        [slideToAcceptStackView, cardSavedLabel, scrollView, rejectButton, cardSceneView, doneButtonView, shareAgainButtonView].forEach { addSubview($0) }
        scrollView.addSubview(mainStackView)
        tagsCollectionViewContainer.addSubview(tagsCollectionView)
    }

    override func configureConstraints() {
        super.configureConstraints()

        let cardSize = Self.defaultCardViewSize
        cardSceneViewWidthConstraint = cardSceneView.constrainWidth(constant: cardSize.width)
        cardSceneViewHeightConstraint = cardSceneView.constrainHeight(constant: cardSize.height)
        cardSceneViewTopConstraint = cardSceneView.constrainTopToSuperviewSafeArea()
        cardSceneView.constrainCenterXToSuperview()

        scrollView.constrainToSuperviewSafeArea()

        cardSavedLabel.constrainCenterXToSuperview()
        cardSavedLabel.constrainCenterY(toView: doneButtonView)

        mainStackView.constrainCenterXToSuperview()
        mainStackView.constrainWidth(constant: Self.defaultCardViewSize.width)
        mainStackView.constrainBottomLessOrEqual(to: scrollView.bottomAnchor, constant: -24)

        tagsTitleLabel.constrainHeight(constant: 26)
        tagsCollectionViewContainer.constrainHeight(constant: 40)

        tagsCollectionView.constrainVerticallyToSuperview()
        tagsCollectionView.constrainCenterXToSuperview()
        tagsCollectionView.constrainWidthEqualTo(self)

        notesTitleLabel.constrainHeight(constant: 26)

        slideToAcceptStackView.constrainCenterXToSuperview()
        slideToAcceptStackViewTopConstraint = slideToAcceptStackView.constrainTopToSuperview(inset: Self.startingSlideToAcceptStackViewTopConstraint)
        slideToAcceptImageView.constrainHeight(constant: 30)

        rejectButton.constrainCenterXToSuperview()
        rejectButton.constrainBottomToSuperviewSafeArea(inset: 20)
        rejectButton.constrainHeight(constant: 50)

        doneButtonViewTopConstraint = doneButtonView.constrainTopToSuperviewSafeArea()
        doneButtonView.constrainTrailingToSuperview(inset: 12)
        doneButtonView.constrainHeight(constant: 50)
        doneButtonView.constrainWidth(constant: 70)

        shareAgainButtonViewTopConstraint = shareAgainButtonView.constrainTopToSuperviewSafeArea()
        shareAgainButtonView.constrainLeadingToSuperview(inset: 12)
        shareAgainButtonView.constrainHeight(constant: 50)
        shareAgainButtonView.constrainWidth(constant: 70)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        cardSceneViewTopConstraint.constant = startingCardTopConstraintConstant
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonsTopInset: CGFloat = safeAreaInsets.top == 0 ? 16 : -4
        doneButtonViewTopConstraint.constant = buttonsTopInset
        shareAgainButtonViewTopConstraint.constant = buttonsTopInset
    }

    override func configureColors() {
        super.configureColors()
        slideToAcceptLabel.textColor = Asset.Colors.appGray.color
        slideToAcceptImageView.tintColor = Asset.Colors.appGray.color
        rejectButton.tintColor = Asset.Colors.appAccent.color

        cardSavedLabel.textColor = .tertiaryLabel
    }

    func prepareForExpandedCardView() {
        cardSceneView.removeFromSuperview()

        scrollView.addSubview(cardSceneView)
        scrollView.alwaysBounceVertical = true

        cardSceneViewTopConstraint = cardSceneView.constrainTopToSuperview(inset: Self.cardViewExpandedTopConstraint)
        cardSceneView.constrainCenterXToSuperview()
        cardSceneView.setDynamicLightingEnabled(true)

        mainStackView.constrainTop(to: cardSceneView.bottomAnchor, constant: 38)
    }
}
