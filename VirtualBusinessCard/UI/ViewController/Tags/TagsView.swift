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
        let this = UITableView(frame: .zero, style: .insetGrouped)
        this.backgroundColor = .clear
        this.registerReusableCell(TagTableCell.self)
        this.separatorStyle = .none
        this.rowHeight = 60
        this.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        addSubview(tableView)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        tableView.constrainToEdgesOfSuperview()
    }
}
