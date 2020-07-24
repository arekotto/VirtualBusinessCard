//
//  CardDetailsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class CardDetailsView: AppBackgroundView {
        
    static let contentInsetTop: CGFloat = 24

    let titleView = TitleView()
    
    let collectionView: UICollectionView = {
        let this = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
        this.registerReusableCell(CardImagesCell.self)
        this.registerReusableCell(TitleValueCollectionCell.self)
        this.registerReusableCell(TitleValueImageCollectionViewCell.self)
        this.registerReusableSupplementaryView(elementKind: SupplementaryElementKind.header.rawValue, RoundedCollectionCell.self)
        this.registerReusableSupplementaryView(elementKind: SupplementaryElementKind.footer.rawValue, RoundedCollectionCell.self)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.backgroundColor = .appBackground
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

private extension CardDetailsView {
    static func createCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            sectionIndex == 0 ? createCollectionViewLayoutCardImagesSection() : createCollectionViewLayoutDetailsSection()
        }
    }
    
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
    
    static func createCollectionViewLayoutDetailsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(50))
        )
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))
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
        
        private(set) var isVisible = false
        
        private var imageViewCenterConstraint: NSLayoutConstraint!
        private let imageView: UIImageView = {
            let this = UIImageView()
            this.contentMode = .scaleAspectFit
            return this
        }()
        
        override func configureView() {
            super.configureView()
            clipsToBounds = true
            constrainWidth(constant: 70)
            constrainHeight(constant: 44)
        }
        
        override func configureSubviews() {
            super.configureSubviews()
            addSubview(imageView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            imageView.constrainWidthEqualTo(self)
            imageView.constrainHeight(constant: 38)
            imageView.constrainCenterXToSuperview()
            imageViewCenterConstraint = imageView.constrainCenterYToSuperview(offset: 50)
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
    }
}

// MARK: - CardImagesCell

extension CardDetailsView {
    final class CardImagesCell: AppCollectionViewCell, Reusable {
                
        let cardFrontBackView = CardFrontBackView()
        
        private var cardFrontBackViewCompactHeightConstraint: NSLayoutConstraint!
        private var cardFrontBackViewCompactWidthConstraint: NSLayoutConstraint!
        
        private var cardFrontBackViewExtendedHeightConstraint: NSLayoutConstraint?
        private var cardFrontBackViewExtendedWidthConstraint: NSLayoutConstraint?
        
        override func configureSubviews() {
            super.configureSubviews()
            addSubview(cardFrontBackView)
            cardFrontBackView.isHidden = true
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            cardFrontBackView.constrainCenterToSuperview()
            cardFrontBackViewCompactWidthConstraint = cardFrontBackView.constrainWidthEqualTo(self,
                multiplier: ReceivedCardsView.CollectionCell.defaultWidthMultiplier
            )
            cardFrontBackViewCompactHeightConstraint = cardFrontBackView.constrainHeightEqualTo(self,
                multiplier: ReceivedCardsView.CollectionCell.defaultHeightMultiplier
            )
        }
        
        func extendWithAnimation() {
            cardFrontBackView.lockViewsToCurrentSizes()

            cardFrontBackViewCompactHeightConstraint.isActive = false
            cardFrontBackViewCompactWidthConstraint.isActive = false
            
            let newWidth = UIScreen.main.bounds.width - 32
            let newOffset = newWidth - cardFrontBackView.frame.width
            
            cardFrontBackViewExtendedWidthConstraint = cardFrontBackView.constrainWidth(constant: newWidth)
            let multi = ReceivedCardsView.CollectionCell.defaultHeightMultiplier
            cardFrontBackViewExtendedHeightConstraint = cardFrontBackView.constrainHeightEqualTo(self, constant: newOffset, multiplier: multi)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
                self.layoutIfNeeded()
            })
        }
        
        func condenseWithAnimation(completion: @escaping () -> Void) {
            
            cardFrontBackViewExtendedWidthConstraint?.isActive = false
            cardFrontBackViewExtendedHeightConstraint?.isActive = false
            cardFrontBackViewCompactHeightConstraint.isActive = true
            cardFrontBackViewCompactWidthConstraint.isActive = true
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
                self.layoutIfNeeded()
            }, completion: { _ in completion() })
        }
    }
}
