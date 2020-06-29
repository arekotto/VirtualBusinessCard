//
//  GroupedCardsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 21/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Kingfisher

final class GroupedCardsView: AppBackgroundView {
    private(set) lazy var scrollableSegmentedControl = ScrollableSegmentedControl()
    
    lazy var tableView: UITableView = {
        let this = UITableView()
        this.rowHeight = 96
        this.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        this.separatorStyle = .none
        this.registerReusableCell(TableCell.self)
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        [tableView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        tableView.constrainToEdgesOfSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollableSegmentedControl.backgroundColor = .appDefaultBackground
        tableView.backgroundColor = .appDefaultBackground
    }
}

// MARK: - TableCell

extension GroupedCardsView {
    final class TableCell: InsetTableCell, Reusable {
        
        private let imageViewStack = ImageViewStack()
        
        private let titleLabel: UILabel = {
            let this = UILabel()
            this.font = UIFont.appDefault(size: 17, weight: .semibold, design: .rounded)
            this.numberOfLines = 2
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
            //            this.numberOfLines = 2
            return this
        }()
        
        private lazy var labelStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, countLabel])
            this.axis = .vertical
            this.spacing = 4
            return this
        }()
        
        override func configureSubviews() {
            super.configureSubviews()
            [imageViewStack, labelStackView].forEach { innerContentView.addSubview($0) }
            selectionStyle = .none
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            imageViewStack.constrainCenterYToSuperview()
            imageViewStack.constrainLeadingToSuperview(inset: 16)
            imageViewStack.constrainSizeToBusinessCardDimensions(width: 100)
            
            labelStackView.constrainLeading(to: imageViewStack.trailingAnchor, constant: 16)
            labelStackView.constrainTrailingToSuperviewMargin()
            labelStackView.constrainCenterYToSuperview()
            labelStackView.constrainTopGreaterOrEqual(to: innerContentView.topAnchor)
            labelStackView.constrainBottomGreaterOrEqual(to: innerContentView.topAnchor)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            subtitleLabel.textColor = .secondaryLabel
            countLabel.textColor = .appAccent
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
            
            titleLabel.text = dm.title
            subtitleLabel.text = dm.subtitle
            countLabel.text = dm.cardCountText
        }
        
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
        
        struct DataModel {
            let frontImageURL: URL?
            let middleImageURL: URL?
            let backImageURL: URL?
            
            let title: String
            let subtitle: String
            let cardCountText: String
        }
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
