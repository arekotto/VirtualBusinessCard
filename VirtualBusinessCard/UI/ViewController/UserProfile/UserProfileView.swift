//
//  UserProfileView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 28/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class UserProfileView: AppBackgroundView {
    lazy var tableView: UITableView = {
        let this = UITableView(frame: .zero, style: .grouped)
        this.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        this.separatorStyle = .none
        this.registerReusableCell(TableCell.self)
        this.registerReusableCell(RoundedInsetTableCell.self)
        this.registerReusableHeaderFooterView(TableHeader.self)
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        [tableView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        tableView.constrainToEdgesOfSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.backgroundColor = .appDefaultBackground
    }
}

// MARK: - TableCell

extension UserProfileView {
    final class TableCell: InsetTableCell, Reusable {
        private let titleLabel: UILabel = {
            let this = UILabel()
            this.font = UIFont.appDefault(size: 13, weight: .medium, design: .rounded)
            this.textColor = .secondaryLabel
            return this
        }()
        
        private let valueLabel: UILabel = {
            let this = UILabel()
            this.font = UIFont.appDefault(size: 17, weight: .medium, design: .rounded)
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
            innerContentView.addSubview(labelStackView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            labelStackView.constrainHorizontallyToSuperview(sideInset: 16)
            labelStackView.constrainCenterYToSuperview()
        }
        
        func setDataModel(_ dataModel: DateModel) {
            titleLabel.text = dataModel.title
            valueLabel.text = dataModel.value
        }
        
        struct DateModel {
            let title: String
            let value: String?
        }
    }
    
    final class TableHeader: AppTableViewHeaderFooterView, Reusable {
        
        var title: String? {
            get { label.text }
            set { label.text = newValue }
        }
        
        private let label: UILabel = {
            let this = UILabel()
            this.font = UIFont.appDefault(size: 15, weight: .medium, design: .rounded)
            return this
        }()
        
        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(label)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            label.constrainCenterYToSuperview()
            label.constrainHorizontallyToSuperview(sideInset: 16)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            label.textColor = .secondaryLabel
            contentView.backgroundColor = .appDefaultBackground
        }
    }
}
