//
//  CompactTagsCollectionView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 26/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol CompactTagsCollectionViewDataSource: class {
    var tagColors: [UIColor] { get }
}

final class CompactTagsCollectionView: UICollectionView {

    weak var tagDataSource: CompactTagsCollectionViewDataSource?
    var targetWidth: CGFloat = 0 {
        didSet {
            setCollectionViewLayout(makeLayout(), animated: false)
        }
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalHeight(1),
                heightDimension: .fractionalHeight(1)
            )
            let section = NSCollectionLayoutSection(group: .horizontal(layoutSize: groupSize, subitems: [item]))
            section.interGroupSpacing = 6
            section.orthogonalScrollingBehavior = .continuous
            let sideInset = (environment.container.contentSize.width - self.targetWidth) / 2
            section.contentInsets = NSDirectionalEdgeInsets(vertical: 0, horizontal: sideInset)

            return section
        }
    }

    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        backgroundColor = .clear
        dataSource = self
        registerReusableCell(Cell.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CompactTagsCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tagDataSource?.tagColors.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.tagImageView.tintColor = tagDataSource?.tagColors[indexPath.item]
        return cell
    }
}

extension CompactTagsCollectionView {
    final class Cell: AppCollectionViewCell, Reusable {

        let tagImageView: UIImageView = {
            let imgConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
            let this = UIImageView(image: UIImage(systemName: "tag.fill", withConfiguration: imgConfig)!.withRenderingMode(.alwaysTemplate))
            this.contentMode = .scaleAspectFit
            return this
        }()

        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(tagImageView)
        }

        override func configureConstraints() {
            super.configureConstraints()
            tagImageView.constrainToEdgesOfSuperview()
        }
    }
}
