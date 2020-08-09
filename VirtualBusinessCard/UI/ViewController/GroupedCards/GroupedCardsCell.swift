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
    
    final class TableCell: AppTableViewCell, Reusable {
        
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

        var dataModel = DataModel() {
            didSet {
                imageViewStack.frontImageView.kf.setImage(with: dataModel.frontImageURL)
                imageViewStack.middleImageView.kf.setImage(with: dataModel.middleImageURL)
                imageViewStack.backImageView.kf.setImage(with: dataModel.backImageURL)

                tagImageView.tintColor = dataModel.tagColor
                tagImageView.isHidden = dataModel.tagColor == nil

                titleLabel.text = dataModel.title
                subtitleLabel.text = dataModel.subtitle
                countLabel.text = dataModel.cardCountText

                updateCardCorners()
                imageViewStack.layoutIfNeeded()
            }
        }

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
            selectedBackgroundView = UIView()
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
            updateCardCorners()
        }

        override func configureColors() {
            super.configureColors()
            subtitleLabel.textColor = .secondaryLabel
            countLabel.textColor = Asset.Colors.appAccent.color
            backgroundColor = Asset.Colors.roundedTableViewCellBackground.color
            selectedBackgroundView?.backgroundColor = Asset.Colors.selectedCellBackgroundLight.color
            tagImageView.tintColor = dataModel.tagColor
        }

        private func updateCardCorners() {
            imageViewStack.frontImageView.layer.cornerRadius = imageViewStack.frontImageView.frame.height * dataModel.frontImageCornerRadiusHeightMultiplier
            imageViewStack.middleImageView.layer.cornerRadius = imageViewStack.middleImageView.frame.height * dataModel.middleImageCornerRadiusHeightMultiplier
            imageViewStack.backImageView.layer.cornerRadius = imageViewStack.backImageView.frame.height * dataModel.backImageCornerRadiusHeightMultiplier
        }
    }
}

// MARK: - DataModel

extension GroupedCardsView.TableCell {

    struct DataModel: Hashable {

        var modelNumber: Int = 0

        var frontImageURL: URL?
        var frontImageCornerRadiusHeightMultiplier: CGFloat = 0

        var middleImageURL: URL?
        var middleImageCornerRadiusHeightMultiplier: CGFloat = 0

        var backImageURL: URL?
        var backImageCornerRadiusHeightMultiplier: CGFloat = 0

        var title = ""
        var subtitle = ""
        var cardCountText = ""

        var tagColor: UIColor?
    }
}

// MARK: - ImageViewStack

extension GroupedCardsView.TableCell {
    
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
