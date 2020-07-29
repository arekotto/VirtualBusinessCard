//
//  TagTableCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class TagTableCell: AppTableViewCell, Reusable {

    var dataModel: DataModel? {
        didSet { didSetDataModel() }
    }

    private let tagImageView: UIImageView = {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let this = UIImageView(image: UIImage(systemName: "tag.fill", withConfiguration: imgConfig)!.withRenderingMode(.alwaysTemplate))
        this.contentMode = .scaleAspectFit
        return this
    }()

    private let tagNameLabel: UILabel = {
        let this = UILabel()
        this.font = UIFont.appDefault(size: 16, weight: .medium, design: .rounded)
        this.numberOfLines = 2
        this.lineBreakMode = .byWordWrapping
        return this
    }()

    private lazy var mainStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [tagImageView, tagNameLabel])
        this.spacing = 16
        return this
    }()

    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(mainStackView)
        selectedBackgroundView = UIView()
    }

    override func configureConstraints() {
        super.configureConstraints()
        tagImageView.constrainWidth(constant: 40)
        mainStackView.constrainToSuperview(topInset: 8, leadingInset: 16, bottomInset: 8, trailingInset: 4)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = Asset.Colors.roundedTableViewCellBackground.color
        selectedBackgroundView?.backgroundColor = Asset.Colors.selectedCellBackgroundLight.color
        accessoryView?.tintColor = Asset.Colors.appAccent.color
    }

    private func didSetDataModel() {
        tagNameLabel.text = dataModel?.tagName
        tagImageView.tintColor = dataModel?.tagColor
        if let accessoryImage = dataModel?.accessoryImage {
            let imageView = UIImageView(image: accessoryImage)
            imageView.tintColor = Asset.Colors.appAccent.color
            accessoryView = imageView
        } else {
            accessoryView = nil
        }
    }

    struct DataModel {
        let tagName: String
        let tagColor: UIColor
        let accessoryImage: UIImage?

        init(tagName: String, tagColor: UIColor, accessoryImage: UIImage? = nil) {
            self.tagName = tagName
            self.tagColor = tagColor
            self.accessoryImage = accessoryImage
        }

    }
}
