//
//  TagsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 10/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class TagsView: AppBackgroundView {
    
    let tableView: UITableView = {
        let this = UITableView()
        this.backgroundColor = .clear
        this.registerReusableCell(TableCell.self)
        this.tableFooterView = UIView()
        this.separatorStyle = .none
        this.rowHeight = 60
        this.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 16, right: 0)
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        addSubview(tableView)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        tableView.constrainVerticallyToSuperview()
        tableView.constrainHorizontallyToSuperview(sideInset: 16)
    }
}

extension TagsView {
    final class TableCell: AppTableViewCell, Reusable {
        
        var dataModel: DataModel? {
            didSet { didSetDataModel() }
        }
                
        private let tagImageView: UIImageView = {
            let imgConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
            let this = UIImageView(image: UIImage(systemName: "tag.fill", withConfiguration: imgConfig)!.withRenderingMode(.alwaysTemplate))
            this.contentMode = .scaleAspectFit
            return this
        }()
        
        private let tagNameLabel: UILabel = {
            let this = UILabel()
            this.font = UIFont.appDefault(size: 16, weight: .medium, design: .rounded)
            this.numberOfLines = 2
            this.lineBreakMode = .byWordWrapping
            return this
        }()
        
        private lazy var mainStackView: UIStackView = {
            let this = UIStackView(arrangedSubviews: [tagImageView, tagNameLabel])
            this.spacing = 16
            return this
        }()
        
        override func configureCell() {
            super.configureCell()
            clipsToBounds = true
        }
        
        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(mainStackView)
            selectedBackgroundView = UIView()
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            tagImageView.constrainWidth(constant: 40)
            mainStackView.constrainToSuperview(topInset: 8, leadingInset: 16, bottomInset: 8, trailingInset: 4)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            backgroundColor = .roundedTableViewCellBackground
            selectedBackgroundView?.backgroundColor = .selectedCellBackgroundLight
            layer.cornerRadius = 8
            updateMaskedCorners()
        }
        
        private func didSetDataModel() {
            tagNameLabel.text = dataModel?.tagName
            tagImageView.tintColor = dataModel?.tagColor
            updateMaskedCorners()
        }
        
        private func updateMaskedCorners() {
            guard let dataModel = self.dataModel else { return }
            if dataModel.isFirstCell && dataModel.isLastCell {
                layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
            } else if dataModel.isFirstCell {
                layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            } else if dataModel.isLastCell {
                layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                layer.maskedCorners = []
            }
        }
        
        struct DataModel {
            let tagName: String
            let tagColor: UIColor
            let isFirstCell: Bool
            let isLastCell: Bool
        }
    }
}
