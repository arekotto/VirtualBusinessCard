//
//  SurfaceEditingView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 02/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension EditCardPhysicalView {
    final class SurfaceEditingView: AppView {

        var specularSlider: UISlider {
            specularEditingView.slider
        }

        var normalSlider: UISlider {
            normalEditingView.slider
        }

        private let specularEditingView: SingleSliderEditingView = {
            let this = SingleSliderEditingView()
            this.minLabel.text = NSLocalizedString("Matte", comment: "")
            this.maxLabel.text = NSLocalizedString("Shiny", comment: "")
            return this
        }()

        private let normalEditingView: SingleSliderEditingView = {
            let this = SingleSliderEditingView()
            this.minLabel.text = NSLocalizedString("Flat", comment: "")
            this.maxLabel.text = NSLocalizedString("Convex", comment: "")
            return this
        }()

        private(set) lazy var mainStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [specularEditingView, normalEditingView])
            this.axis = .vertical
            this.distribution = .fillEqually
            this.spacing = 8
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
    }
}
