//
//  SingleSliderEditingView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension EditCardPhysicalView {
    final class SingleSliderEditingView: AppView {
        let slider: UISlider = {
            let this = UISlider()
            return this
        }()

        let minLabel: UILabel = {
            let this = UILabel()
            this.font = .appDefault(size: 13, weight: .regular)
            return this
        }()

        let maxLabel: UILabel = {
            let this = UILabel()
            this.font = .appDefault(size: 13, weight: .regular)
            this.setContentHuggingPriority(.required, for: .horizontal)
            return this
        }()

        private lazy var labelStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [minLabel, maxLabel])
            return this
        }()

        private lazy var mainStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [labelStackView, slider])
            this.axis = .vertical
            this.spacing = 2
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            addSubview(mainStackView)
        }

        override func configureConstraints() {
            super.configureConstraints()
            mainStackView.constrainToEdgesOfSuperview()
        }

        override func configureColors() {
            super.configureColors()
            slider.tintColor = Asset.Colors.appAccent.color

            minLabel.textColor = Asset.Colors.secondaryText.color
            maxLabel.textColor = Asset.Colors.secondaryText.color
        }
    }
}
