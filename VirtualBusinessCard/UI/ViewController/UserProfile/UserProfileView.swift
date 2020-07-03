//
//  UserProfileView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 28/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class UserProfileView: AppBackgroundView {
    
    private(set) lazy var collectionView: UICollectionView = {
        let this = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
        this.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        this.registerReusableCell(TitleValueCollectionCell.self)
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
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(50))
            )
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                        
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(10))
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerFooterSize,
                    elementKind: SupplementaryElementKind.header.rawValue,
                    alignment: .top
                ),
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerFooterSize,
                    elementKind: SupplementaryElementKind.footer.rawValue,
                    alignment: .bottom
                )
            ]
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            return section
        }
    }

    enum SupplementaryElementKind: String {
        case header
        case footer
    }
}

// MARK: - TableHeader

extension UserProfileView {
    final class TableHeader: AppTableViewHeaderFooterView, Reusable {
        
        var title: String? {
            get { label.text }
            set { label.text = newValue }
        }
        
        private let label: UILabel = {
            let this = UILabel()
            this.font = UIFont.appDefault(size: 15, weight: .medium, design: .rounded)
            return this
        }()
        
        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(label)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            label.constrainCenterYToSuperview()
            label.constrainHorizontallyToSuperview(sideInset: 16)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            label.textColor = .secondaryLabel
            contentView.backgroundColor = .appDefaultBackground
        }
    }
}
