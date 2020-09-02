//
//  CardDetailsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class CardDetailsView: AppBackgroundView {
        
    static let contentInsetTop: CGFloat = -30

    let titleView = TitleView()
    
    let collectionView: UICollectionView = {
        let this = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        this.registerReusableCell(CardImagesCell.self)
        this.registerReusableCell(TitleValueCollectionCell.self)
        this.registerReusableCell(TitleValueImageCollectionViewCell.self)
        this.registerReusableCell(TagCell.self)
        this.registerReusableCell(NoTagsCell.self)
        this.registerReusableCell(UpdateAvailableCell.self)
        this.registerReusableCell(DeleteCell.self)
        this.registerReusableSupplementaryView(elementKind: SupplementaryElementKind.header.rawValue, RoundedCollectionCell.self)
        this.registerReusableSupplementaryView(elementKind: SupplementaryElementKind.footer.rawValue, RoundedCollectionCell.self)
        this.alwaysBounceVertical = true
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        [collectionView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.constrainToEdgesOfSuperview()
    }
    
    override func configureColors() {
        super.configureColors()
        collectionView.backgroundColor = Asset.Colors.appBackground.color
    }
}

// MARK: - GroupedCardsView

extension CardDetailsView {

    enum SupplementaryElementKind: String {
        case header
        case footer
    }
}

// MARK: - Static functions

extension CardDetailsView {
    
    static func createCollectionViewLayoutCardImagesSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        )
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(ReceivedCardsView.CollectionCell.defaultHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: Self.contentInsetTop, leading: 0, bottom: 16, trailing: 0)
        return section
    }

    static func createCollectionViewLayoutCardImagesFullyExpandedSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                            widthDimension: .fractionalWidth(1),
                                            heightDimension: .fractionalHeight(1))
        )
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute( 1.8 * ReceivedCardsView.CollectionCell.defaultHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: Self.contentInsetTop, leading: 0, bottom: 16, trailing: 0)
        return section
    }

    static func createCollectionViewLayoutDynamicSection() -> NSCollectionLayoutSection {
        let estimatedHeight = NSCollectionLayoutDimension.estimated(30)
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: estimatedHeight
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        let bottomOffset: CGFloat = 24
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: bottomOffset, trailing: 16)
        return section
    }

    static func createCollectionViewLayoutUpdateSection() -> NSCollectionLayoutSection {
        let estimatedHeight = NSCollectionLayoutDimension.estimated(200)
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: estimatedHeight
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        return section
    }

    static func createCollectionViewLayoutDetailsSection() -> NSCollectionLayoutSection {
        let estimatedHeight = NSCollectionLayoutDimension.estimated(60)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: estimatedHeight
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: estimatedHeight)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(10))
        
        let section = NSCollectionLayoutSection(group: group)
        let bottomOffset: CGFloat = 24
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: bottomOffset, trailing: 16)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: SupplementaryElementKind.header.rawValue,
                alignment: .top,
                absoluteOffset: .init(x: 0, y: 20)
            ),
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: SupplementaryElementKind.footer.rawValue,
                alignment: .bottom,
                absoluteOffset: .init(x: 0, y: -bottomOffset)
            )
        ]
        return section
    }
}

// MARK: - TitleView

extension CardDetailsView {
    
    final class TitleView: AppView {

        var cardCornerRadiusHeightMultiplier: CGFloat = 0 {
            didSet { updateCornerRadius() }
        }
        
        private(set) var isVisible = false
        
        private var imageViewCenterConstraint: NSLayoutConstraint!
        private let imageView: UIImageView = {
            let this = UIImageView()
            this.clipsToBounds = true
            return this
        }()
        
        override func configureView() {
            super.configureView()
            clipsToBounds = true
        }
        
        override func configureSubviews() {
            super.configureSubviews()
            addSubview(imageView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            constrainSizeToBusinessCardDimensions(width: 64)
            imageView.constrainWidthEqualTo(self)
            imageView.constrainHeightEqualTo(self)
            imageView.constrainCenterXToSuperview()
            imageViewCenterConstraint = imageView.constrainCenterYToSuperview(offset: 50)
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            updateCornerRadius()
        }

        func setImageURL(_ url: URL?) {
            imageView.kf.setImage(with: url)
        }
        
        func animateSlideIn() {
            imageViewCenterConstraint.constant = 0
            isVisible = true
            UIView.animate(withDuration: 0.5) {
                self.alpha = 1
                self.layoutIfNeeded()
            }
        }
        
        func animateSlideOut() {
            imageViewCenterConstraint.constant = 50
            isVisible = false
            UIView.animate(withDuration: 0.5) {
                self.alpha = 0
                self.layoutIfNeeded()
            }
        }

        private func updateCornerRadius() {
            imageView.layer.cornerRadius = imageView.frame.height * cardCornerRadiusHeightMultiplier
        }
    }
}
