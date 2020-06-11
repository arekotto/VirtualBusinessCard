//
//  PersonalBusinessCardsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 02/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CollectionViewPagingLayout

final class PersonalBusinessCardsView: AppView {
    
    let collectionView: UICollectionView = {
        let layout = CollectionViewPagingLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.clipsToBounds = false
        cv.registerReusableCell(BusinessCardCell.self)
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
        collectionView.constrainCenterYToSuperview()
        collectionView.constrainHorizontallyToSuperview()
        collectionView.constrainHeight(constant: 400)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor(named: "AppDefaultBackgroud")
    }
}

