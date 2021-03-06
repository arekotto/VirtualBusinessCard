//
//  TransparentButtonView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 27/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class TransparentButtonView: UIView {

    let shapeIntoCircle: Bool

    let button: UIButton = {
        let this = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
//        this.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        return this
    }()

    private let effectBackground: UIVisualEffectView

    init(style: UIBlurEffect.Style, shapeIntoCircle: Bool) {
        effectBackground = UIVisualEffectView(effect: UIBlurEffect(style: style))
        self.shapeIntoCircle = shapeIntoCircle
        super.init(frame: .zero)
        clipsToBounds = true

        [effectBackground, button].forEach { addSubview($0) }
        button.constrainToEdgesOfSuperview()
        effectBackground.constrainToEdgesOfSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if shapeIntoCircle {
            layer.cornerRadius = bounds.height / 2
        }
        button.backgroundColor = Asset.Colors.appGray.color.withAlphaComponent(0.1)
        button.tintColor = Asset.Colors.appAccent.color
        button.setTitleColor(Asset.Colors.appAccent.color, for: .normal)
    }

    func setSystemImage(_ name: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: name, withConfiguration: config), for: .normal)
    }
}
