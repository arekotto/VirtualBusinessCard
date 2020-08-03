//
//  TextureEditingView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 02/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension EditCardPhysicalView {
    final class TextureEditingView: AppView {

        let collectionView: UICollectionView = {
            let this = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
            this.translatesAutoresizingMaskIntoConstraints = false
            this.alwaysBounceVertical = false
            this.registerReusableCell(TextureCollectionCell.self)
            this.backgroundColor = .clear
            this.allowsMultipleSelection = false
            return this
        }()

        let addTextureImageButton: UIButton = {
            let this = UIButton()
            this.setTitle(NSLocalizedString("Select Custom Image", comment: ""), for: .normal)
            this.titleLabel?.font = .appDefault(size: 15)
            return this
        }()

        private lazy var mainStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [collectionView, addTextureImageButton])
            this.axis = .vertical
            this.spacing = 4
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            addSubview(mainStackView)
        }

        override func configureConstraints() {
            super.configureConstraints()
            mainStackView.constrainToEdgesOfSuperview()
        }

        override func configureColors() {
            super.configureColors()
            addTextureImageButton.setTitleColor(Asset.Colors.appAccent.color, for: .normal)
        }
    }
}

// MARK: - Static functions

extension EditCardPhysicalView.TextureEditingView {
    private static func collectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        section.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: section)
    }
}
