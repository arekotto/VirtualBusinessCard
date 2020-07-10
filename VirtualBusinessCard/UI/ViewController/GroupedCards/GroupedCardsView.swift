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

    let collectionView: UICollectionView = {
        let this = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        this.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        this.registerReusableCell(CollectionCell.self)
        this.registerReusableSupplementaryView(elementKind: SupplementaryElementKind.collectionViewHeader.rawValue, CollectionHeader.self)
        this.registerReusableSupplementaryView(elementKind: SupplementaryElementKind.sectionHeader.rawValue, RoundedCollectionCell.self)
        this.registerReusableSupplementaryView(elementKind: SupplementaryElementKind.sectionFooter.rawValue, RoundedCollectionCell.self)
        this.isScrollEnabled = true
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.backgroundColor = .appDefaultBackground
    }
}

// MARK: - GroupedCardsView

extension GroupedCardsView {
    enum SupplementaryElementKind: String {
        case collectionViewHeader
        case sectionHeader
        case sectionFooter
    }
}

// MARK: - Collection View Layout

private extension GroupedCardsView {
    static func collectionViewLayout() -> UICollectionViewLayout {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        )
        
        let sideInset: CGFloat = 16
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(96))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sideInset, bottom: 0, trailing: sideInset)
        
        let bottomOffset: CGFloat = 24
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: bottomOffset, trailing: 0)
        section.boundarySupplementaryItems = boundarySupplementaryItems(bottomOffset: bottomOffset, edgeInset: sideInset)

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    static func boundarySupplementaryItems(bottomOffset: CGFloat, edgeInset: CGFloat) -> [NSCollectionLayoutBoundarySupplementaryItem] {
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(10))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SupplementaryElementKind.sectionHeader.rawValue,
            alignment: .top,
            absoluteOffset: .init(x: 0, y: 20)
        )
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: edgeInset, bottom: 0, trailing: edgeInset)
        
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SupplementaryElementKind.sectionFooter.rawValue,
            alignment: .bottom,
            absoluteOffset: .init(x: 0, y: -bottomOffset)
        )
        sectionFooter.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: edgeInset, bottom: 0, trailing: edgeInset)
        
        let collectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
            elementKind: SupplementaryElementKind.collectionViewHeader.rawValue,
            alignment: .top,
            absoluteOffset: .init(x: 0, y: 0)
        )
        collectionHeader.pinToVisibleBounds = true
        return [sectionHeader, sectionFooter, collectionHeader]
    }
}

// MARK: - SegmentedControlHeader

extension GroupedCardsView {
    final class CollectionHeader: AppCollectionViewCell, Reusable {
        
        let mainStackView = UIStackView()
        
        override func layoutSubviews() {
            super.layoutSubviews()
            backgroundColor = .appDefaultBackground
        }
        
        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(mainStackView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            mainStackView.constrainToEdgesOfSuperview()
        }
    }
}

