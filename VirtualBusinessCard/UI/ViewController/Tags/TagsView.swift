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

    let emptyStateView = EmptyStateView(
        title: NSLocalizedString("No Tags to Show", comment: ""),
        subtitle: NSLocalizedString("Create new tags by tapping the + button in the top right corner.", comment: ""),
        isHidden: true
    )
    
    override func configureSubviews() {
        super.configureSubviews()
        [tableView, emptyStateView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        tableView.constrainToEdgesOfSuperview()

        emptyStateView.constrainWidthEqualTo(self, multiplier: 0.8)
        emptyStateView.constrainCenterToSuperview()
    }
}
