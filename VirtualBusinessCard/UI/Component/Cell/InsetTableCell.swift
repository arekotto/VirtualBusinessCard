//
//  InsetTableCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 22/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

class InsetTableCell: AppTableViewCell {
        
    let innerContentView: UIView = {
        let this = UIView()
        this.clipsToBounds = true
        return this
    }()
    
    override func configureCell() {
        super.configureCell()
        backgroundColor = nil
        selectionStyle = .none
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.innerContentView.backgroundColor = selected ? .appDefaultBackground : .roundedTableViewCellBackground
            }
        } else {
            innerContentView.backgroundColor = selected ? .appDefaultBackground : .roundedTableViewCellBackground
        }
    }
}

final class RoundedInsetTableCell: InsetTableCell, Reusable {
    
    static let cornerRadius: CGFloat = 8

    override func configureCell() {
        super.configureCell()
        selectionStyle = .none
    }
    
    func configureRoundedCorners(mode: RoundedCornersMode) {
        innerContentView.layer.cornerRadius = Self.cornerRadius
        switch mode {
        case .top: innerContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom: innerContentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    enum RoundedCornersMode {
        case top, bottom
    }
}
