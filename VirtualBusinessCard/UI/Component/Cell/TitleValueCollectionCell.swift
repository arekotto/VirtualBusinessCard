//
//  TitleValueCollectionCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 29/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class TitleValueCollectionCell: AppCollectionViewCell, Reusable {
    
    override var isSelected: Bool {
        get { super.isSelected }
        set {
            super.isSelected = newValue
            didUpdateSelected()
        }
    }
    
    var isMultiLine = true {
        didSet { valueLabel.numberOfLines = isMultiLine ? 0 : 1 }
    }
    
    private let titleLabel: UILabel = {
        let this = UILabel()
        this.font = UIFont.appDefault(size: 13, weight: .medium, design: .rounded)
        return this
    }()
    
    private let valueLabel: UILabel = {
        let this = UILabel()
        this.font = UIFont.appDefault(size: 17, weight: .medium, design: .rounded)
        this.numberOfLines = 0
        return this
    }()
    
    private lazy var labelStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        this.axis = .vertical
        this.spacing = 4
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(labelStackView)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        labelStackView.constrainHorizontallyToSuperview(sideInset: 16)
        labelStackView.constrainCenterYToSuperview()
        labelStackView.constrainTopGreaterOrEqual(to: contentView.topAnchor, constant: 10, priority: .defaultHigh)
        labelStackView.constrainBottomLessOrEqual(to: contentView.bottomAnchor, constant: -10, priority: .defaultHigh)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .roundedTableViewCellBackground
        titleLabel.textColor = .secondaryLabel
    }
    
    func setDataModel(_ dataModel: DataModel) {
        titleLabel.text = dataModel.title
        valueLabel.text = dataModel.value
    }
    
    private func didUpdateSelected() {
        if isSelected {
            contentView.backgroundColor = .appBackground
        } else {
            UIView.animate(withDuration: 0.5) {
                self.contentView.backgroundColor = .roundedTableViewCellBackground
            }
        }
    }
    
    struct DataModel {
        let title: String
        let value: String?
    }
}
