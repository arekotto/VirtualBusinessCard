//
//  SettingsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class SettingsView: AppView {
    let collectionView: UICollectionView = {
        let this = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
        this.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        this.registerReusableCell(TitleAccessoryImageCollectionCell.self)
        this.registerReusableCell(TitleCollectionCell.self)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.backgroundColor = .appDefaultBackground
    }
    
    enum SupplementaryElementKind: String {
        case header
        case footer
    }
}

// MARK: - Static functions

extension SettingsView {
    private static func createCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(50))
            )
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let headerFooterHeight: CGFloat = 10
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(headerFooterHeight))
            
            let section = NSCollectionLayoutSection(group: group)

            let verticalInset: CGFloat = 24
            section.contentInsets = NSDirectionalEdgeInsets(top: verticalInset, leading: 16, bottom: verticalInset, trailing: 16)
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerFooterSize,
                    elementKind: SupplementaryElementKind.header.rawValue,
                    containerAnchor: .init(edges: .top, absoluteOffset: CGPoint(x: 0, y: verticalInset - headerFooterHeight))
                ),
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerFooterSize,
                    elementKind: SupplementaryElementKind.footer.rawValue,
                    containerAnchor: .init(edges: .bottom, absoluteOffset: CGPoint(x: 0, y: -verticalInset + headerFooterHeight))
                )
            ]
            return section
        }
    }
}
