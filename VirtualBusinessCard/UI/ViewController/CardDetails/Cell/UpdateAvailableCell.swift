//
//  UpdateAvailableCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 26/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension CardDetailsView {

    final class UpdateAvailableCell: AppCollectionViewCell, Reusable {

        private let titleLabel: UILabel = {
            let this = UILabel()
            this.text = NSLocalizedString("Update Available", comment: "")
            this.font = .appDefault(size: 17, weight: .semibold)
            this.textAlignment = .center
            return this
        }()

        private let descriptionLabel: UILabel = {
            let this = UILabel()
            this.font = .appDefault(size: 13)
            this.text = NSLocalizedString(
                "The user who shared this card with you has issued an update to it. The update might contain changes to the card's appearance as well as changes to the contact information. You can choose to skip this update now and download it at a later time.",
                comment: ""
            )
            this.numberOfLines = 0
            this.lineBreakMode = .byWordWrapping
            this.textAlignment = .center
            return this
        }()

        let updateButton: UIButton = {
            let this = UIButton()
            this.setTitle(NSLocalizedString("Download Update", comment: ""), for: .normal)
            return this
        }()

        private lazy var mainStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, updateButton])
            this.spacing = 16
            this.axis = .vertical
            return this
        }()

        override func configureCell() {
            super.configureCell()
            contentView.layer.borderWidth = 1
            contentView.layer.cornerRadius = 16
        }

        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(mainStackView)
        }

        override func configureConstraints() {
            super.configureConstraints()
            mainStackView.constrainToEdgesOfSuperview(inset: 12)
            mainStackView.constrainHeightGreaterThanOrEqualTo(constant: 60)
        }

        override func configureColors() {
            super.configureColors()
            updateButton.setTitleColor(Asset.Colors.appAccent.color, for: .normal)
            descriptionLabel.textColor = .secondaryLabel
            contentView.layer.borderColor = Asset.Colors.appAccent.color.withAlphaComponent(0.6).cgColor
        }
    }
}
