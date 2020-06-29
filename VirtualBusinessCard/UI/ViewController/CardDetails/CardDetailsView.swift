//
//  CardDetailsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class CardDetailsView: AppBackgroundView {
    
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
