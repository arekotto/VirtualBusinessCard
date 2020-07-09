//
//  PersonalCardsCompactView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class PersonalCardsCompactView: AppBackgroundView {

    let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewExtendedLayout())
        cv.showsHorizontalScrollIndicator = false
        cv.clipsToBounds = false
        cv.registerReusableCell(CollectionCell.self)
        cv.backgroundColor = .clear
        return cv
    }()

    override func configureSubviews() {
        super.configureSubviews()
        addSubview(collectionView)
    }

    override func configureConstraints() {
        super.configureConstraints()
        collectionView.constrainToEdgesOfSuperview()
    }


    private static func makeCollectionViewExtendedLayout() -> UICollectionViewLayout {

        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        )
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }

    final class CollectionCell: AppCollectionViewCell, Reusable {

        var heightConst: NSLayoutConstraint!

        let cardView = UIView()
        let innerContentView = UIView()

        override func configureSubviews() {
            super.configureSubviews()
            cardView.backgroundColor = [UIColor.red, UIColor.orange, UIColor.blue, UIColor.green, UIColor.purple, UIColor.systemPink].randomElement()

            cardView.layer.cornerRadius = 16
            cardView.clipsToBounds = true


            [cardView].forEach { innerContentView.addSubview($0) }
            contentView.addSubview(innerContentView)
        }

        override func configureConstraints() {

            cardView.constrainTopToSuperview()
            cardView.constrainHorizontallyToSuperview(sideInset: 16)
            cardView.constrainHeight(constant: 200)
            cardView.constrainBottomToSuperview().isActive = false

            innerContentView.constrainToEdgesOfSuperview()
            heightConst = innerContentView.constrainHeight(constant: 100)

        }
    }
}
