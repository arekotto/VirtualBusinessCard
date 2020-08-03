//
//  HorizontalOrDivider.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class HorizontalOrDivider: AppView {

    private let leadingHorizontalDivider: UIView = {
        let this = UIView()
        return this
    }()

    private let trailingHorizontalDivider: UIView = {
        let this = UIView()
        return this
    }()

    private let orLabel: UILabel = {
        let this = UILabel()
        this.text = NSLocalizedString("OR", comment: "")
        this.textAlignment = .center
        this.font = UIFont.appDefault(size: 16, weight: .light)
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        [leadingHorizontalDivider, orLabel, trailingHorizontalDivider].forEach { addSubview($0) }
    }

    override func configureConstraints() {
        super.configureConstraints()

        orLabel.constrainCenterToSuperview()
        leadingHorizontalDivider.constrainCenterYToSuperview()
        trailingHorizontalDivider.constrainCenterYToSuperview()

        leadingHorizontalDivider.constrainLeadingToSuperview()
        leadingHorizontalDivider.constrainTrailing(to: orLabel.leadingAnchor, constant: -16)

        trailingHorizontalDivider.constrainTrailingToSuperview()
        trailingHorizontalDivider.constrainLeading(to: orLabel.trailingAnchor, constant: 16)

        leadingHorizontalDivider.constrainHeight(constant: 1)
        trailingHorizontalDivider.constrainHeight(constant: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        leadingHorizontalDivider.backgroundColor = Asset.Colors.appGray.color
        trailingHorizontalDivider.backgroundColor = Asset.Colors.appGray.color
        orLabel.textColor = Asset.Colors.appGray.color
    }
}
