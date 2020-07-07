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
        cv.backgroundColor = nil
        cv.keyboardDismissMode = .onDrag
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
        let cellSize: CardFrontBackView.SizeMode
        
        func layout() -> UICollectionViewLayout {
            switch cellSize {
            case .compact: return createCollectionViewCompactLayout()
            case .expanded: return createCollectionViewExtendedLayout()
            }
        }
    }
    
    private static func createCollectionViewExtendedLayout() -> UICollectionViewLayout {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(CollectionCell.defaultHeight))
        )
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private static func createCollectionViewCompactLayout() -> UICollectionViewLayout {
        
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
