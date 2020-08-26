//
//  DeleteCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 26/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension CardDetailsView {

    final class DeleteCell: AppCollectionViewCell, Reusable {

        let deleteButton: UIButton = {
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
            let image = UIImage(systemName: "trash.fill", withConfiguration: imageConfig)?.withRenderingMode(.alwaysTemplate)
            let this = UIButton()
            this.setImage(image, for: .normal)
            return this
        }()

        private let imageContainer: UIView = {
            let this = UIView()
            this.layer.cornerRadius = 12
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            imageContainer.addSubview(deleteButton)
            contentView.addSubview(imageContainer)
        }

        override func configureConstraints() {
            super.configureConstraints()

            deleteButton.constrainToEdgesOfSuperview(inset: 6)

            imageContainer.constrainCenterXToSuperview()
            imageContainer.constrainVerticallyToSuperview()
            imageContainer.constrainWidth(constant: 60)
            imageContainer.constrainHeight(to: imageContainer.widthAnchor, priority: .defaultHigh)
        }

        override func configureColors() {
            super.configureColors()
            deleteButton.tintColor = Asset.Colors.appAccent.color
            imageContainer.backgroundColor = Asset.Colors.roundedTableViewCellBackground.color
        }
    }
}
