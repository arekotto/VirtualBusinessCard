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
            
    private(set) lazy var collectionView: UICollectionView = {
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
        collectionView.backgroundColor = .appDefaultBackground
    }
    
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            sectionIndex == 0 ? self?.createCollectionViewLayoutCardImagesSection() : self?.createCollectionViewLayoutDetailsSection()
        }
    }
    
    private func createCollectionViewLayoutCardImagesSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        )
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(CardImagesCell.defaultHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: Self.contentInsetTop, leading: 0, bottom: 32, trailing: 0)
        return section
    }
    
    private func createCollectionViewLayoutDetailsSection() -> NSCollectionLayoutSection {
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
    
    enum SupplementaryElementKind: String {
        case header
        case footer
    }
}

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

extension CardDetailsView {
    final class CardImagesCell: AppCollectionViewCell, Reusable {
        
        static let defaultHeight: CGFloat = 240
        
        let cardFrontBackView = CardFrontBackView()
        
        private var cardFrontBackViewHeightConstraint: NSLayoutConstraint!
        private var cardFrontBackViewWidthConstraint: NSLayoutConstraint!
        
        override func configureSubviews() {
            super.configureSubviews()
            addSubview(cardFrontBackView)
            cardFrontBackView.isHidden = true
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            cardFrontBackView.constrainCenterXToSuperview()
            cardFrontBackView.constrainTopToSuperview()
            let cardsOffset = UIScreen.main.bounds.width * 0.06
            cardFrontBackViewWidthConstraint = cardFrontBackView.constrainWidth(constant: CardFrontBackView.defaultCardSize.width + cardsOffset)
            cardFrontBackViewHeightConstraint = cardFrontBackView.constrainHeight(constant: CardFrontBackView.defaultCardSize.height + cardsOffset)
        }
        
        func extendWithAnimation() {
            let screenWidth = UIScreen.main.bounds.width
            let heightOffset = screenWidth * 0.1
            cardFrontBackViewHeightConstraint.constant = CardFrontBackView.defaultCardSize.height + heightOffset
            cardFrontBackViewWidthConstraint.constant = UIScreen.main.bounds.width - 32
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
        
        func condenseWithAnimation(completion: @escaping () -> Void) {
            let cardsOffset = UIScreen.main.bounds.width * 0.06
            cardFrontBackViewHeightConstraint.constant = CardFrontBackView.defaultCardSize.height + cardsOffset
            cardFrontBackViewWidthConstraint.constant = CardFrontBackView.defaultCardSize.width + cardsOffset
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                completion()
            })
        }
    }
}
