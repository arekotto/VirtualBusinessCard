//
//  PersonalCardLocalizationsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class PersonalCardLocalizationsView: AppBackgroundView {

    let tableView: UITableView = {
        let this = UITableView(frame: .zero, style: .insetGrouped)
        this.backgroundColor = .clear
        this.registerReusableCell(LocalizationCell.self)
        this.registerReusableCell(PushUpdateCell.self)
        this.separatorStyle = .none
        this.estimatedRowHeight = 200
        this.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        addSubview(tableView)
    }

    override func configureConstraints() {
        super.configureConstraints()
        tableView.constrainToEdgesOfSuperview()
    }
}

// MARK: - LocalizationCell

extension PersonalCardLocalizationsView {

    final class LocalizationCell: AppTableViewCell, Reusable {

        let cardSceneView: CardFrontBackView = {
            let this = CardFrontBackView(sceneHeightAdjustMode: .flexible(multiplayer: 1))
            this.setSceneShadowOpacity(0.2)
            return this
        }()

        private let languageTitleLabel: UILabel = {
            let this = UILabel()
            this.font = .appDefault(size: 18, weight: .medium, design: .rounded)
            return this
        }()

        private let defaultLabel: UILabel = {
            let this = UILabel()
            this.text = NSLocalizedString("Default", comment: "")
            this.font = .appDefault(size: 15)
            return this
        }()

        private lazy var labelStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [languageTitleLabel, defaultLabel])
            this.translatesAutoresizingMaskIntoConstraints = false
            return this
        }()

        private let contentBackgroundView: UIView = {
            let this = UIView()
            this.clipsToBounds = true
            this.layer.cornerRadius = 12
            this.backgroundColor = Asset.Colors.roundedTableViewCellBackground.color
            return this
        }()

        private lazy var mainStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [cardSceneView, labelStackView])
            this.axis = .vertical
            this.spacing = 8
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            addSubview(contentBackgroundView)
            addSubview(mainStackView)
            selectedBackgroundView = {
                let this = UIView()
                this.layer.cornerRadius = 14
                return this
            }()
        }

        override func configureConstraints() {
            super.configureConstraints()
            mainStackView.constrainToEdgesOfSuperview(inset: 24)
            cardSceneView.constrainHeight(to: cardSceneView.widthAnchor, constant: -2, multiplier: CGSize.businessCardHeightToWidthRatio * 0.5)

            contentBackgroundView.constrainToEdgesOfSuperview(inset: 8)
        }

        override func configureColors() {
            super.configureColors()
            selectedBackgroundView?.backgroundColor = Asset.Colors.selectedCellBackgroundStrong.color
            backgroundColor = Asset.Colors.appBackground.color
            defaultLabel.textColor = .secondaryLabel
        }
    }
}

extension PersonalCardLocalizationsView.LocalizationCell {

    func setDataModel(_ dataModel: DataModel) {
        languageTitleLabel.text = dataModel.title
        defaultLabel.isHidden = !dataModel.isDefault
        cardSceneView.setDataModel(dataModel.sceneDataModel)
    }

    struct DataModel: Hashable {
        let id: UUID
        let title: String
        let isDefault: Bool
        let sceneDataModel: CardFrontBackView.URLDataModel
    }
}

// MARK: - PushUpdateCell

extension PersonalCardLocalizationsView {

    final class PushUpdateCell: AppTableViewCell, Reusable {

        private let titleLabel: UILabel = {
            let this = UILabel()
            this.text = NSLocalizedString("Update Available to Share", comment: "")
            this.font = .appDefault(size: 17, weight: .semibold)
            this.textAlignment = .center
            return this
        }()

        private let descriptionLabel: UILabel = {
            let this = UILabel()
            this.font = .appDefault(size: 13)
            this.text = NSLocalizedString(
                "You have updated this card recently and can make these changes available for download to users who have received this card from you in past.",
                comment: ""
            )
            this.numberOfLines = 0
            this.lineBreakMode = .byWordWrapping
            this.textAlignment = .center
            return this
        }()

        let updateButton: UIButton = {
            let this = UIButton()
            this.setTitle(NSLocalizedString("Share Update", comment: ""), for: .normal)
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
            selectionStyle = .none
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
            backgroundColor = Asset.Colors.appBackground.color
            contentView.layer.borderColor = Asset.Colors.appAccent.color.withAlphaComponent(0.6).cgColor
        }
    }
}
