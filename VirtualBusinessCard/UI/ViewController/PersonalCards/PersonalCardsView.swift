//
//  PersonalCardsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 02/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CollectionViewPagingLayout

final class PersonalCardsView: AppBackgroundView {
    
    var visibleCells: [CollectionCell] {
        collectionView.visibleCells as? [CollectionCell] ?? []
    }
    
    let collectionView: UICollectionView = {
        let layout = CollectionViewPagingLayout()
        layout.numberOfVisibleItems = 3
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.clipsToBounds = false
        cv.registerReusableCell(CollectionCell.self)
        cv.backgroundColor = .clear
        return cv
    }()

    let emptyStateView = EmptyStateView(
        title: NSLocalizedString("No Business Cards to Show", comment: ""),
        subtitle: NSLocalizedString("Add your personal cards by tapping the + button in the top right corner.", comment: ""),
        isHidden: true
    )
    
    override func configureView() {
        super.configureView()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        [collectionView, emptyStateView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.constrainCenterYToSuperview()
        collectionView.constrainHorizontallyToSuperview()
        collectionView.constrainHeight(constant: 400)

        emptyStateView.constrainWidthEqualTo(self, multiplier: 0.8)
        emptyStateView.constrainCenterToSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
