//
//  GroupedCardsCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 10/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Kingfisher

extension GroupedCardsView {
    final class CollectionCell: AppCollectionViewCell, Reusable {
        
        private static func fetchImage(url: URL, andSetTo imageView: UIImageView) {
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let imageResult):
                    imageView.image = imageResult.image
                case .failure(let err):
                    imageView.image = nil
                    print("Error fetching image:", err.localizedDescription)
                }
            }
        }
        
        override var isSelected: Bool {
            get { super.isSelected }
            set {
                super.isSelected = newValue
                didUpdateSelected()
            }
        }

        private var tagColor: UIColor?

        private let imageViewStack = ImageViewStack()
        
        private let titleLabel: UILabel = {
            let this = UILabel()
            this.font = UIFont.appDefault(size: 17, weight: .semibold, design: .rounded)
            this.numberOfLines = 2
            this.lineBreakMode = .byWordWrapping
            return this
        }()

        private let tagImageView: UIImageView = {
            let imgConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            let this = UIImageView(image: UIImage(systemName: "tag.fill", withConfiguration: imgConfig))
            this.isHidden = true
            this.contentMode = .scaleAspectFit
            return this
        }()

        private lazy var titleStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [tagImageView, titleLabel])
            this.spacing = 4
            return this
        }()
        
        private let subtitleLabel: UILabel = {
            let this = UILabel()
            this.font = UIFont.appDefault(size: 13, weight: .regular, design: .rounded)
            return this
        }()
        
        private let countLabel: UILabel = {
            let this = UILabel()
            this.font = UIFont.appDefault(size: 13, weight: .medium, design: .rounded)
            return this
        }()
        
        private lazy var labelStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [titleStackView, subtitleLabel, countLabel])
            this.axis = .vertical
            this.spacing = 4
            return this
        }()
        
        override func configureSubviews() {
            super.configureSubviews()
            [imageViewStack, labelStackView].forEach { contentView.addSubview($0) }
        }
        
        override func configureConstraints() {
            super.configureConstraints()

            tagImageView.constrainWidth(constant: 24)

            imageViewStack.constrainCenterYToSuperview()
            imageViewStack.constrainLeadingToSuperview(inset: 16)
            imageViewStack.constrainSizeToBusinessCardDimensions(width: 100)
            
            labelStackView.constrainLeading(to: imageViewStack.trailingAnchor, constant: 16)
            labelStackView.constrainTrailingToSuperviewMargin()
            labelStackView.constrainCenterYToSuperview()
            labelStackView.constrainTopGreaterOrEqual(to: contentView.topAnchor)
            labelStackView.constrainBottomGreaterOrEqual(to: contentView.topAnchor)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            subtitleLabel.textColor = .secondaryLabel
            countLabel.textColor = .appAccent
            contentView.backgroundColor = .roundedTableViewCellBackground
            tagImageView.tintColor = tagColor
        }
        
        func setDataModel(_ dm: DataModel) {
            
            if let frontImageURL = dm.frontImageURL {
                Self.fetchImage(url: frontImageURL, andSetTo: imageViewStack.frontImageView)
            } else {
                imageViewStack.frontImageView.image = nil
            }
            
            if let middleImageURL = dm.middleImageURL {
                Self.fetchImage(url: middleImageURL, andSetTo: imageViewStack.middleImageView)
            } else {
                imageViewStack.middleImageView.image = nil
            }
            
            if let backImageURL = dm.backImageURL {
                Self.fetchImage(url: backImageURL, andSetTo: imageViewStack.backImageView)
            } else {
                imageViewStack.backImageView.image = nil
            }

            tagColor = dm.tagColor
            if let tagColor = dm.tagColor {
                tagImageView.tintColor = tagColor
                tagImageView.isHidden = false
            } else {
                tagImageView.isHidden = true
            }

            titleLabel.text = dm.title
            subtitleLabel.text = dm.subtitle
            countLabel.text = dm.cardCountText
        }
        
        func didUpdateSelected() {
            if isSelected {
                contentView.backgroundColor = .appBackground
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.contentView.backgroundColor = .roundedTableViewCellBackground
                }
            }
        }
        
        struct DataModel {
            let frontImageURL: URL?
            let middleImageURL: URL?
            let backImageURL: URL?
            
            let title: String
            let subtitle: String
            let cardCountText: String

            let tagColor: UIColor?
        }
    }
}

// MARK: - ImageViewStack

extension GroupedCardsView.CollectionCell {
    
    private final class ImageViewStack: AppView {
        
        private static func imageView() -> UIImageView {
            let this = UIImageView()
            this.clipsToBounds = true
            return this
        }
        
        private static func rotate(view: UIView, byAngle angle: CGFloat) {
            let radians = angle / 180.0 * CGFloat.pi
            let rotation = view.transform.rotated(by: radians)
            view.transform = rotation
        }
        
        let imageViewsRotateAngles: [CGFloat] = [-10, 10, 0]
        
        let frontImageView = imageView()
        let middleImageView = imageView()
        let backImageView = imageView()
        
        private var imageViews: [UIImageView] {
            [backImageView, middleImageView, frontImageView]
        }
        
        override func configureSubviews() {
            super.configureSubviews()
            imageViews.enumerated().forEach { idx, view in
                addSubview(view)
                let angleToRotate = imageViewsRotateAngles[idx]
                guard angleToRotate != 0 else { return }
                Self.rotate(view: view, byAngle: angleToRotate)
            }
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            imageViews.forEach { $0.constrainToEdgesOfSuperview() }
        }
    }
}
