//
//  TitleCollectionViewCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 10/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class TitleCollectionCell: AppCollectionViewCell, Reusable {
    
    private var titleColor: UIColor = Asset.Colors.defaultText.color {
        didSet {
            titleLabel.textColor = titleColor
        }
    }
    
    override var isSelected: Bool {
        get { super.isSelected }
        set {
            super.isSelected = newValue
            didUpdateSelected()
        }
    }
    
    var isMultiLine = true {
        didSet { titleLabel.numberOfLines = isMultiLine ? 0 : 1 }
    }
    
    private let titleLabel: UILabel = {
        let this = UILabel()
        this.font = UIFont.appDefault(size: 17, weight: .medium, design: .rounded)
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(titleLabel)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        titleLabel.constrainHorizontallyToSuperview(leadingInset: 16, trailingInset: 8)
        titleLabel.constrainCenterYToSuperview()
        titleLabel.constrainTopGreaterOrEqual(to: contentView.topAnchor, constant: 10, priority: .defaultHigh)
        titleLabel.constrainBottomLessOrEqual(to: contentView.bottomAnchor, constant: -10, priority: .defaultHigh)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = Asset.Colors.roundedTableViewCellBackground.color
        titleLabel.textColor = titleColor
    }
    
    func setTitle(_ title: String, color: UIColor) {
        titleLabel.text = title
        titleColor = Asset.Colors.appAccent.color
    }
    
    private func didUpdateSelected() {
        if isSelected {
            contentView.backgroundColor = Asset.Colors.appBackground.color
        } else {
            UIView.animate(withDuration: 0.5) {
                self.contentView.backgroundColor = Asset.Colors.roundedTableViewCellBackground.color
            }
        }
    }
}
