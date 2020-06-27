//
//  ReceivedCardsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 15/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class ReceivedCardsView: AppBackgroundView {
    
    let cellSizeModeButton = UIButton(type: .system)
    
    let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: ReceivedCardsCollectionViewLayout())
        cv.registerReusableCell(BusinessCardCell.self)
        cv.backgroundColor = nil
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        [collectionView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        collectionView.constrainToEdgesOfSuperview()
        
        cellSizeModeButton.constrainHeight(constant: 32)
        cellSizeModeButton.constrainWidth(constant: 32)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension ReceivedCardsView {
    struct CollectionViewLayoutFactory {
        let cellSize: ReceivedCardsVM.CellSizeMode
        
        func layout() -> UICollectionViewLayout {
            switch cellSize {
            case .compact: return CompactCellLayout()
            case .expanded: return ExpandedCellLayout()
            }
        }
        
    }

    class ReceivedCardsCollectionViewLayout: UICollectionViewFlowLayout {
        
        static let screenWidth = UIScreen.main.bounds.size.width
        
        override init() {
            super.init()
            let inset = Self.screenWidth * 0.05
            sectionInset = UIEdgeInsets(top: 30, left: inset, bottom: 30, right: inset)
            minimumLineSpacing = 30
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
            guard let cv = collectionView, let firstVisibleItem = cv.indexPathsForVisibleItems.min() else { return proposedContentOffset }
            let isShowingFirstItem = firstVisibleItem.item == 0
            return isShowingFirstItem ? cv.contentOffset : proposedContentOffset
        }
    }

    final class ExpandedCellLayout: ReceivedCardsCollectionViewLayout {
        override var itemSize: CGSize {
            set {}
            get {
                let cardSize = CGSize.businessCardSize(width: Self.screenWidth * 0.8)
                let cardsOffset = Self.screenWidth * 0.06
                return CGSize(width: cardSize.width + cardsOffset, height: cardSize.height + cardsOffset)
            }
        }
    }

    class CompactCellLayout: ReceivedCardsCollectionViewLayout {
        override var itemSize: CGSize {
            set {}
            get { CGSize.businessCardSize(width: Self.screenWidth * 0.4) }
        }
    }
}
