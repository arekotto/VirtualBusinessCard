//
//  NoTagsCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 26/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension CardDetailsView {

    final class NoTagsCell: AppCollectionViewCell, Reusable {

        let addTagsButton: UIButton = {
            let this = UIButton()
            this.setTitle(NSLocalizedString("Add Tags", comment: ""), for: .normal)
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            let image = UIImage(systemName: "tag.fill", withConfiguration: imageConfig)
            this.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
            this.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            addSubview(addTagsButton)
        }

        override func configureConstraints() {
            super.configureConstraints()
            addTagsButton.constrainToEdgesOfSuperview()
            addTagsButton.constrainHeightGreaterThanOrEqualTo(constant: 20)
        }

        override func configureColors() {
            super.configureColors()
            addTagsButton.setTitleColor(Asset.Colors.appAccent.color, for: .normal)
            addTagsButton.tintColor = Asset.Colors.appAccent.color
        }
    }
}
