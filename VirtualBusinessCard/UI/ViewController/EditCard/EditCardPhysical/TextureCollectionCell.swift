//
//  TextureCollectionCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 02/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension EditCardPhysicalView {
    final class TextureCollectionCell: AppCollectionViewCell, Reusable {

        override var isSelected: Bool {
            get { super.isSelected }
            set {
                super.isSelected = newValue
                selectionIndicatorView.backgroundColor = newValue ? Asset.Colors.appGray.color.withAlphaComponent(0.2) : .clear
            }
        }

        private let selectionIndicatorView: UIView = {
            let this = UIView()
            this.layer.cornerRadius = 12
            this.clipsToBounds = true
            return this
        }()

        private let textureImageView: UIImageView = {
            let this = UIImageView()
            this.layer.cornerRadius = 12
            this.clipsToBounds = true
            return this
        }()

        override func configureCell() {
            super.configureCell()
            contentView.layer.cornerRadius = 12
            contentView.clipsToBounds = true
        }

        override func configureSubviews() {
            super.configureSubviews()
            [selectionIndicatorView, textureImageView].forEach { contentView.addSubview($0) }
        }

        override func configureConstraints() {
            super.configureConstraints()
            textureImageView.constrainToEdgesOfSuperview(inset: 8)
            selectionIndicatorView.constrainToEdgesOfSuperview()
        }

        func setDataModel(_ dataModel: DataModel) {
            textureImageView.image = dataModel.textureImage
        }
    }
}

// MARK: - DataModel

extension EditCardPhysicalView.TextureCollectionCell {
    struct DataModel {
        let textureImage: UIImage
    }
}
