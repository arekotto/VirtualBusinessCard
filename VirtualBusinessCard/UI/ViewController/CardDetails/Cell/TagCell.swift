//
//  TagCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 26/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension CardDetailsView {

    final class TagCell: AppCollectionViewCell, Reusable {

        private var tagImageViewColor: UIColor? {
            didSet { tagImageView.tintColor = tagImageViewColor }
        }

        private let tagImageView: UIImageView = {
            let imageCong = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            let image = UIImage(systemName: "tag.fill", withConfiguration: imageCong)
            let this = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
            this.contentMode = .scaleAspectFit
            return this
        }()

        let titleLabel: UILabel = {
            let this = UILabel()
            this.font = .appDefault(size: 16, weight: .semibold)
            return this
        }()

        private lazy var stackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [tagImageView, titleLabel])
            this.spacing = 4
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            addSubview(stackView)
        }

        override func configureConstraints() {
            super.configureConstraints()
            stackView.constrainVerticallyToSuperview(topInset: 2, bottomInset: 2)
            titleLabel.constrainCenterX(to: contentView.centerXAnchor)
            stackView.constrainLeadingGreaterOrEqual(to: contentView.leadingAnchor, constant: 16)
            stackView.constrainTrailingLessOrEqual(to: contentView.trailingAnchor, constant: -16)
            stackView.constrainHeightGreaterThanOrEqualTo(constant: 30, priority: .defaultHigh)
        }

        override func configureColors() {
            super.configureColors()
            tagImageView.tintColor = tagImageViewColor
        }
    }
}

extension CardDetailsView.TagCell {

    struct DataModel: Hashable {
        var tagID: BusinessCardTagID
        var title: String
        var tagColor: UIColor?
    }

    func setDataModel(_ dataModel: DataModel) {
        titleLabel.text = dataModel.title
        tagImageViewColor = dataModel.tagColor
    }
}
