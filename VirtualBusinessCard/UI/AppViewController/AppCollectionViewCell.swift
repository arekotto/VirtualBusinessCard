//
//  AppCollectionViewCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 22/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

class AppCollectionViewCell: UICollectionViewCell {
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell() { }

    func configureSubviews() { }

    func configureConstraints() { }
}
