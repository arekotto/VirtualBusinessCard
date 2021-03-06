//
//  EditCardImagesView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 31/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardImagesView: AppBackgroundView {

    static let defaultCardViewSize = CGSize.businessCardSize(width: UIScreen.main.bounds.width * 0.8)

    let titleView = NavigationTitleView()

    let frontImageButton: UIButton = {
        let this = UIButton()
        this.setTitle(NSLocalizedString("Choose Front Image", comment: ""), for: .normal)
        this.layer.cornerRadius = 12
        return this
    }()

    let backImageButton: UIButton = {
        let this = UIButton()
        this.setTitle(NSLocalizedString("Choose Back Image", comment: ""), for: .normal)
        return this
    }()

    private let frontImageButtonContainer = UIView()
    private let backImageButtonContainer = UIView()

    private let frontSideLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("Front Side", comment: "")
        this.font = .appDefault(size: 15, weight: .medium)
        return this
    }()

    private let backSideLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("Back Side", comment: "")
        this.font = .appDefault(size: 15, weight: .medium)
        return this
    }()

    private let frontImageView: UIImageView = {
        let this = UIImageView()
        this.layer.shadowRadius = 9
        return this
    }()

    private let backImageView: UIImageView = {
        let this = UIImageView()
        this.layer.shadowRadius = 9
        return this
    }()

    private lazy var frontImageStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [frontImageView, frontImageButtonContainer])
        this.axis = .vertical
        switch DeviceDisplay.sizeType {
        case .compact, .standard: this.spacing = 12
        case .commodious: this.spacing = 16
        }
        return this
    }()

    private lazy var backImageStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [backImageView, backImageButtonContainer])
        this.axis = .vertical
        switch DeviceDisplay.sizeType {
        case .compact, .standard: this.spacing = 12
        case .commodious: this.spacing = 16
        }
        return this
    }()

    private lazy var mainStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [frontImageStackView, backImageStackView])
        this.axis = .vertical
        switch DeviceDisplay.sizeType {
        case .compact, .standard: this.spacing = 24
        case .commodious: this.spacing = 32
        }
        return this
    }()

    private let mainScrollView: UIScrollView = {
        let this = UIScrollView()
        this.alwaysBounceVertical = true
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        frontImageButtonContainer.addSubview(frontImageButton)
        backImageButtonContainer.addSubview(backImageButton)
        [frontSideLabel, backSideLabel, mainStackView].forEach { mainScrollView.addSubview($0) }
        addSubview(mainScrollView)
    }

    override func configureConstraints() {
        super.configureConstraints()
        frontImageView.constrainSizeToBusinessCardDimensions(width: UIScreen.main.bounds.width * 0.8)
        backImageView.constrainSizeToBusinessCardDimensions(width: UIScreen.main.bounds.width * 0.8)

        frontImageButtonContainer.constrainHeightEqualTo(frontImageView, multiplier: 0.22)
        backImageButtonContainer.constrainHeightEqualTo(frontImageView, multiplier: 0.22)

        frontImageButton.constrainHeightEqualTo(frontImageButtonContainer)
        frontImageButton.constrainCenterToSuperview()
        frontImageButton.constrainWidthEqualTo(frontImageButtonContainer, multiplier: 0.7)

        backImageButton.constrainHeightEqualTo(backImageButtonContainer)
        backImageButton.constrainCenterToSuperview()
        backImageButton.constrainWidthEqualTo(backImageButtonContainer, multiplier: 0.7)

        frontSideLabel.constrainCenter(toView: frontImageView)
        backSideLabel.constrainCenter(toView: backImageView)

        let verticalInsets: CGFloat
        switch DeviceDisplay.sizeType {
        case .compact, .standard: verticalInsets = 24
        case .commodious: verticalInsets = 32
        }
        mainStackView.constrainCenterXToSuperview()
        mainStackView.constrainCenterYToSuperview(offset: -50, priority: .defaultLow)
        mainStackView.constrainTopGreaterOrEqual(to: mainScrollView.topAnchor, constant: verticalInsets)
        mainStackView.constrainBottomLessOrEqual(to: mainScrollView.bottomAnchor, constant: -verticalInsets)

        mainScrollView.constrainToEdgesOfSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        frontImageButton.layer.cornerRadius = frontImageButton.frame.height / 4
        backImageButton.layer.cornerRadius = backImageButton.frame.height / 4
    }

    override func configureColors() {
        super.configureColors()
        frontImageButton.setTitleColor(Asset.Colors.appAccent.color, for: .normal)
        frontImageButton.backgroundColor = Asset.Colors.roundedTableViewCellBackground.color

        backImageButton.setTitleColor(Asset.Colors.appAccent.color, for: .normal)
        backImageButton.backgroundColor = Asset.Colors.roundedTableViewCellBackground.color

        frontSideLabel.textColor = Asset.Colors.appGray.color
        frontImageView.backgroundColor = Asset.Colors.appGray.color.withAlphaComponent(0.1)

        backSideLabel.textColor = Asset.Colors.appGray.color
        backImageView.backgroundColor = Asset.Colors.appGray.color.withAlphaComponent(0.1)
    }

    func setFrontImage(_ image: UIImage?) {
        if let newImage = image {
            frontImageView.image = newImage
            frontImageView.layer.shadowOpacity = CardFrontBackView.defaultSceneShadowOpacity
        } else {
            frontImageView.layer.shadowOpacity = 0
            frontImageView.image = nil
        }
    }

    func setBackImage( _ image: UIImage?) {
        if let newImage = image {
            backImageView.image = newImage
            backImageView.layer.shadowOpacity = CardFrontBackView.defaultSceneShadowOpacity
        } else {
            backImageView.layer.shadowOpacity = 0
            backImageView.image = nil
        }
    }
}
