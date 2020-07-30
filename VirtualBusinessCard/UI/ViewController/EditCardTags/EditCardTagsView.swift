//
//  EditCardTagsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardTagsView: AppBackgroundView {

    let tableView: UITableView = {
        let this = UITableView(frame: .zero, style: .insetGrouped)
        this.backgroundColor = .clear
        this.registerReusableCell(TagTableCell.self)
        this.tableFooterView = UIView()
        this.separatorStyle = .none
        this.separatorColor = .clear
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
        tableView.constrainHorizontallyToSuperview(sideInset: 0)
    }
}
