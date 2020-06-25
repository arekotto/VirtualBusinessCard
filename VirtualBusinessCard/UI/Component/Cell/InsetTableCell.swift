//
//  InsetTableCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 22/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

class InsetTableCell: AppTableViewCell {
    
    static let cornerRadius: CGFloat = 14
    
    let innerContentView: UIView = {
        let this = UIView()
        this.layer.cornerRadius = cornerRadius
        this.clipsToBounds = true
        return this
    }()
    
    override func configureCell() {
        super.configureCell()
        backgroundColor = nil
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(innerContentView)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        innerContentView.constrainToSuperview(topInset: 0, leadingInset: 16, bottomInset: 0, trailingInset: 16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        innerContentView.backgroundColor = .roundedTableViewCellBackground
    }
    
    func setRoundedCornersMode(_ mode: RoundedCornersMode) {
        switch mode {
        case .top:
            innerContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            innerContentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        case .all:
            innerContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        case .none:
            innerContentView.layer.maskedCorners = []
        }
    }
    
    enum RoundedCornersMode {
        case top, bottom, all, none
    }
}
