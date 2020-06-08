//
//  PersonalBusinessCardsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 02/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Kingfisher

struct BusinessCardDimensions {
    
    let size: CGSize
    
    init(width: CGFloat) {
        size = CGSize(width: width, height: width * 55 / 85)
    }
    
}

final class PersonalBusinessCardsView: AppView {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let screenWidth = UIScreen.main.bounds.size.width
        let dimensions = BusinessCardDimensions(width: screenWidth * 0.8)
        layout.itemSize = dimensions.size
        layout.minimumInteritemSpacing = screenWidth * 0.05
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.registerReusableCell(BusinessCardCell.self)
        return cv
    }()
    
    
    override func configureView() {
        super.configureView()
        backgroundColor = .white
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        addSubview(collectionView)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.constrainTopToSuperviewSafeArea()
        collectionView.constrainHorizontallyToSuperview()
        collectionView.constrainHeight(constant: 200)
    }
    
    class BusinessCardCell: AppCollectionViewCell, Reusable {
        
        var dataModel = BusinessCardCellDM(imageURL: nil) {
            didSet {
                if let imageURL = dataModel.imageURL {
                    imageView.kf.indicatorType = .activity
                    imageView.kf.setImage(
                        with: imageURL,
                        placeholder: UIImage(named: "placeholderImage"),
                        options: [
//                            .processor(processor),
                            .scaleFactor(UIScreen.main.scale),
                            .transition(.fade(1)),
                            .cacheOriginalImage
                        ])
                }
                
            }
        }
        
        let imageView: UIImageView = {
            let iv = UIImageView()
            return iv
        }()
        
        override func configureSubviews() {
            super.configureSubviews()
            addSubview(imageView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            imageView.constrainToEdgesOfSuperview()
        }
    }
    
    struct BusinessCardCellDM {
        let imageURL: URL?
    }
}
