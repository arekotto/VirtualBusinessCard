//
//  LoadingPopoverView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class LoadingPopoverView: AppView {

    let titleLabel: UILabel = {
        let this = UILabel()
        this.setContentCompressionResistancePriority(.required, for: .horizontal)
        this.font = .appDefault(size: 16, weight: .semibold, design: .rounded)
        return this
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let this = UIActivityIndicatorView(style: .large)
        this.startAnimating()
        return this
    }()

    private let effectView: UIView = {
        let this = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        this.clipsToBounds = true
        this.layer.cornerRadius = 20
        return this
    }()

    private lazy var mainStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [activityIndicator, titleLabel])
        this.axis = .vertical
        this.spacing = 16
        return this
    }()

    override func configureView() {
        super.configureView()
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }

    override func configureSubviews() {
        super.configureSubviews()
        [effectView, mainStackView].forEach { addSubview($0) }
    }

    override func configureConstraints() {
        super.configureConstraints()

        effectView.constrainHeight(constant: 200)
        effectView.constrainWidth(constant: 200)
        effectView.constrainCenterToSuperview()

        activityIndicator.constrainHeight(constant: 50)

        mainStackView.constrainCenterToSuperview()
    }

    override func configureColors() {
        super.configureColors()
        activityIndicator.color = .appAccent
        titleLabel.textColor = .secondaryText
    }
}
