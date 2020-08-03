//
//  HapticsEditingView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension EditCardPhysicalView {
    final class HapticsEditingView: AppView {

        var slider: UISlider {
            hapticsEditingView.slider
        }

        private let hapticsEditingView: SingleSliderEditingView = {
            let this = SingleSliderEditingView()
            this.minLabel.text = NSLocalizedString("Soft", comment: "")
            this.maxLabel.text = NSLocalizedString("Sharp", comment: "")
            this.slider.isContinuous = false
            return this
        }()

        private let descriptionLabel: UILabel = {
            let this = UILabel()
            this.text = NSLocalizedString("Select the sharpness of haptic feedback played to users interacting with your card on their devices. This feature is only supported on iPhone 7 or newer.", comment: "")
            this.font = .appDefault(size: 13)
            this.textAlignment = .center
            this.numberOfLines = 0
            this.lineBreakMode = .byWordWrapping
            this.minimumScaleFactor = 0.5
            return this
        }()

        private lazy var mainStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [hapticsEditingView, descriptionLabel])
            this.axis = .vertical
            this.spacing = 8
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            addSubview(mainStackView)
        }

        override func configureConstraints() {
            super.configureConstraints()
            mainStackView.constrainCenterYToSuperview()
            mainStackView.constrainHorizontallyToSuperview(sideInset: 32)
            hapticsEditingView.constrainHeight(to: heightAnchor, constant: -20, multiplier: 0.5)
        }

        override func configureColors() {
            super.configureColors()
            descriptionLabel.textColor = .secondaryLabel
        }
    }
}
