//
//  EditCardView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 31/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardView: AppBackgroundView {

    static let defaultCardViewSize = CGSize.businessCardSize(width: UIScreen.main.bounds.width * 0.8)

    let frontImageView: UIImageView = {
        let this = UIImageView()
        this.layer.borderWidth = 1
        this.layer.borderColor = Asset.Colors.appAccent.color.cgColor
        return this
    }()

    let frontImageButton: UIButton = {
        let this = UIButton()
        this.setTitle(NSLocalizedString("Choose Front Side Image", comment: ""), for: .normal)
        return this
    }()

    let backImageView: UIImageView = {
        let this = UIImageView()
        //        this.
        return this
    }()

    let backImageButton: UIButton = {
        let this = UIButton()
        this.setTitle(NSLocalizedString("Choose Back Side Image", comment: ""), for: .normal)
        return this
    }()

    private lazy var frontImageStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [frontImageView, frontImageButton])
        this.axis = .vertical
        this.spacing = 4
        return this
    }()

    private lazy var backImageStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [backImageView, backImageButton])
        this.axis = .vertical
        this.spacing = 4
        return this
    }()

    private lazy var mainStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [frontImageStackView, backImageStackView])
        this.axis = .vertical
        this.spacing = 16
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        [mainStackView].forEach { addSubview($0) }
    }

    override func configureConstraints() {
        super.configureConstraints()
        frontImageView.constrainSizeToBusinessCardDimensions(width: UIScreen.main.bounds.width * 0.8)
        backImageView.constrainSizeToBusinessCardDimensions(width: UIScreen.main.bounds.width * 0.8)

        mainStackView.constrainCenterXToSuperview()
        mainStackView.constrainTopToSuperviewSafeArea()

        frontImageButton.constrainHeight(constant: 50)
        backImageButton.constrainHeight(constant: 50)
    }
}
