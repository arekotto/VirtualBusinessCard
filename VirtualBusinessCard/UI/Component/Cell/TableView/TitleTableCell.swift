//
//  TitleTableCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class TitleTableCell: AppTableViewCell, Reusable {

    var dataModel: DataModel? {
        didSet {
            titleLabel.textColor = dataModel?.titleColor
            titleLabel.text = dataModel?.title
            if let accessoryImage = dataModel?.accessoryImage {
                let imageView = UIImageView(image: accessoryImage)
                imageView.tintColor = Asset.Colors.appAccent.color
                accessoryView = imageView
            } else {
                accessoryView = nil
            }
        }
    }

    var isMultiLine = true {
        didSet { titleLabel.numberOfLines = isMultiLine ? 0 : 1 }
    }

    private let titleLabel: UILabel = {
        let this = UILabel()
        this.font = UIFont.appDefault(size: 17, weight: .medium, design: .rounded)
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(titleLabel)
        selectedBackgroundView = UIView()
    }

    override func configureConstraints() {
        super.configureConstraints()
        titleLabel.constrainHorizontallyToSuperview(leadingInset: 16, trailingInset: 8)
        titleLabel.constrainCenterYToSuperview()
        titleLabel.constrainTopGreaterOrEqual(to: contentView.topAnchor, constant: 10, priority: .defaultHigh)
        titleLabel.constrainBottomLessOrEqual(to: contentView.bottomAnchor, constant: -10, priority: .defaultHigh)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.textColor = dataModel?.titleColor
        selectedBackgroundView?.backgroundColor = Asset.Colors.selectedCellBackgroundLight.color
        accessoryView?.tintColor = Asset.Colors.appAccent.color
    }

    struct DataModel {
        let title: String
        let titleColor: UIColor
        let accessoryImage: UIImage?

        init(title: String, titleColor: UIColor = Asset.Colors.defaultText.color, accessoryImage: UIImage? = nil) {
            self.title = title
            self.titleColor = titleColor
            self.accessoryImage = accessoryImage
        }
    }
}
