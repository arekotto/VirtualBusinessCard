//
//  PersonalCardVersionsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class PersonalCardVersionsView: AppBackgroundView {

    let tableView: UITableView = {
        let this = UITableView(frame: .zero, style: .insetGrouped)
        this.backgroundColor = .clear
        this.registerReusableCell(TableCell.self)
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

// MARK: - TableCell

extension PersonalCardVersionsView {

    final class TableCell: AppTableViewCell, Reusable {

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

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            contentBackgroundView.backgroundColor = selected ? Asset.Colors.selectedCellBackgroundStrong.color : Asset.Colors.roundedTableViewCellBackground.color

        }

        override func configureSubviews() {
            super.configureSubviews()
            addSubview(contentBackgroundView)
            addSubview(mainStackView)
            selectedBackgroundView = UIView()
        }

        override func configureConstraints() {
            super.configureConstraints()
            mainStackView.constrainToEdgesOfSuperview(inset: 24)
            cardSceneView.constrainHeight(to: cardSceneView.widthAnchor, constant: -2, multiplier: CGSize.businessCardHeightToWidthRatio * 0.5)

            contentBackgroundView.constrainToEdgesOfSuperview(inset: 8)
        }

        override func configureColors() {
            super.configureColors()
            backgroundColor = Asset.Colors.appBackground.color
            defaultLabel.textColor = .secondaryLabel
            contentBackgroundView.backgroundColor = isSelected ? Asset.Colors.selectedCellBackgroundStrong.color : Asset.Colors.roundedTableViewCellBackground.color
        }
    }
}

extension PersonalCardVersionsView.TableCell {

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
