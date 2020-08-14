//
//  ReceivedCardsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 15/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class ReceivedCardsView: AppBackgroundView {
    
    let cellSizeModeButton = UIButton(type: .system)

    let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.registerReusableCell(CollectionCell.self)
        cv.registerReusableSupplementaryView(elementKind: SupplementaryView.updateAvailableIndicator.rawValue, UpdateAvailableIndicator.self)
        cv.backgroundColor = nil
        cv.keyboardDismissMode = .onDrag
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        [collectionView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.constrainToEdgesOfSuperview()
        
        cellSizeModeButton.constrainHeight(constant: 32)
        cellSizeModeButton.constrainWidth(constant: 32)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - CollectionViewLayoutFactory

extension ReceivedCardsView {
    
    struct CollectionViewLayoutFactory {
        let style: CardFrontBackView.Style
        
        func layout() -> UICollectionViewLayout {
            switch style {
            case .compact: return makeCollectionViewCompactLayout()
            case .expanded: return makeCollectionViewExtendedLayout()
            }
        }
    }
    
    private static func makeCollectionViewExtendedLayout() -> UICollectionViewLayout {

        let updateBadgeAnchor = NSCollectionLayoutAnchor(
            edges: [.top, .trailing],
            fractionalOffset: CGPoint(x: -0.5, y: 0.5)
        )

        let updateBadge = NSCollectionLayoutSupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(20),
                heightDimension: .absolute(20)
            ),
            elementKind: SupplementaryView.updateAvailableIndicator.rawValue,
            containerAnchor: updateBadgeAnchor
        )

        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(CollectionCell.defaultHeight)),
            supplementaryItems: [updateBadge]
        )
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private static func makeCollectionViewCompactLayout() -> UICollectionViewLayout {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1))
        )
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(CollectionCell.defaultHeight * 0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - SupplementaryView

extension ReceivedCardsView {

    enum SupplementaryView: String {
        case updateAvailableIndicator
    }
}

// MARK: - UpdateAvailableIndicator

extension ReceivedCardsView {

    final class UpdateAvailableIndicator: UICollectionReusableView, Reusable {

        private let imageView: UIImageView = {
            let imgConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            let this = UIImageView(image: UIImage(systemName: "arrow.down.circle", withConfiguration: imgConfig))
            return this
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(imageView)
            imageView.constrainToEdgesOfSuperview()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            imageView.tintColor = Asset.Colors.appAccent.color
        }
    }
}
