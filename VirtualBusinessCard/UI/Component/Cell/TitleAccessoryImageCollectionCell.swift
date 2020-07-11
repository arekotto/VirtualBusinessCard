//
//  TitleAccessoryImageCollectionCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 10/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class TitleAccessoryImageCollectionCell: AppCollectionViewCell, Reusable {
    
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
    
    private let accessoryImageView: UIImageView = {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold, scale: .medium)
        let this = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: imgConfig))
        this.contentMode = .center
        return this
    }()
    
    private lazy var labelStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [titleLabel, accessoryImageView])
        this.spacing = 4
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(labelStackView)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        accessoryImageView.constrainWidth(constant: 30)
        labelStackView.constrainHorizontallyToSuperview(leadingInset: 16, trailingInset: 8)
        labelStackView.constrainCenterYToSuperview()
        labelStackView.constrainTopGreaterOrEqual(to: contentView.topAnchor, constant: 10, priority: .defaultHigh)
        labelStackView.constrainBottomLessOrEqual(to: contentView.bottomAnchor, constant: -10, priority: .defaultHigh)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .roundedTableViewCellBackground
        accessoryImageView.tintColor = .appAccent
    }
    
    private func didUpdateSelected() {
        if isSelected {
            contentView.backgroundColor = .appDefaultBackground
        } else {
            UIView.animate(withDuration: 0.5) {
                self.contentView.backgroundColor = .roundedTableViewCellBackground
            }
        }
    }
    
    func setDataModel(_ dataModel: DataModel) {
        titleLabel.text = dataModel.title
        accessoryImageView.image = dataModel.accessoryImage
    }
    
    struct DataModel {
        let title: String
        let accessoryImage: UIImage
    }
}
