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
    
    override func configureView() {
        super.configureView()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        addSubview(collectionView)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.constrainCenterYToSuperview(offset: -50)
        collectionView.constrainHorizontallyToSuperview()
        collectionView.constrainHeight(constant: 400)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
