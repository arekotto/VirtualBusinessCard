//
//  UICollectionView+Extensions.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 06/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

// MARK: - CollectionView + Reusable

extension UICollectionView {
    func registerReusableCell<T: UICollectionViewCell>(_: T.Type) where T: Reusable {
        register(T.self, forCellWithReuseIdentifier: T.reuseId)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T where T: Reusable {
        dequeueReusableCell(withReuseIdentifier: T.reuseId, for: indexPath) as! T
    }
    
    func registerReusableSupplementaryView<T: Reusable>(elementKind: String, _: T.Type) {
        register(T.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: T.reuseId)
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionViewCell>(elementKind: String, indexPath: IndexPath) -> T where T: Reusable {
        dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: T.reuseId, for: indexPath) as! T
    }
}
