//
//  RoundedCollectionCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 29/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class RoundedCollectionCell: AppCollectionViewCell, Reusable {
    
    static let cornerRadius: CGFloat = 8
    
    override func configureCell() {
        super.configureCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = Asset.Colors.roundedTableViewCellBackground.color
    }
    
    func configureRoundedCorners(mode: RoundedCornersMode) {
        contentView.layer.cornerRadius = Self.cornerRadius
        switch mode {
        case .top: contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom: contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    enum RoundedCornersMode {
        case top, bottom
    }
}
