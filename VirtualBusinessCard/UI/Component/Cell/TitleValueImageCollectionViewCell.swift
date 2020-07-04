//
//  TitleValueImageCollectionViewCell.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class TitleValueImageCollectionViewCell: AppCollectionViewCell, Reusable {
    
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
        this.textColor = .secondaryLabel
        return this
    }()
    
    private let valueLabel: UILabel = {
        let this = UILabel()
        this.font = UIFont.appDefault(size: 17, weight: .medium, design: .rounded)
        this.numberOfLines = 0
        return this
    }()
    
    private let imageView: UIImageView = {
        let this = UIImageView()
        this.contentMode = .center
        this.clipsToBounds = true
        return this
    }()
    
    private lazy var labelStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        this.axis = .vertical
        this.spacing = 4
        return this
    }()
    
    private lazy var mainStackView: UIStackView = {
        let this = UIStackView(arrangedSubviews: [labelStackView, imageView])
        this.spacing = 4
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(mainStackView)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        mainStackView.constrainHorizontallyToSuperview(sideInset: 16)
        mainStackView.constrainCenterYToSuperview()
        mainStackView.constrainTopGreaterOrEqual(to: contentView.topAnchor, constant: 10, priority: .defaultHigh)
        mainStackView.constrainBottomLessOrEqual(to: contentView.bottomAnchor, constant: -10, priority: .defaultHigh)
        
        imageView.constrainWidth(constant: 32)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .roundedTableViewCellBackground
        imageView.tintColor = .appAccent
    }
    
    func setDataModel(_ dataModel: DataModel) {
        titleLabel.text = dataModel.title
        valueLabel.text = dataModel.value
        imageView.image = dataModel.primaryImage
    }
    
    func didUpdateSelected() {
        if isSelected {
            contentView.backgroundColor = .appDefaultBackground
        } else {
            UIView.animate(withDuration: 0.5) {
                self.contentView.backgroundColor = .roundedTableViewCellBackground
            }
        }
    }
    
    struct DataModel {
        
        let title: String
        let value: String?
        
        let primaryImage: UIImage?
        
        init(title: String, value: String?, primaryImage: UIImage?) {
            self.title = title
            self.value = value
            self.primaryImage = primaryImage
        }
    }
}
