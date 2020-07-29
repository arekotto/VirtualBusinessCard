//
//  SettingsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class SettingsView: AppView {
    let tableView: UITableView = {
        let this = UITableView(frame: .zero, style: .insetGrouped)
        this.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        this.registerReusableCell(TitleTableCell.self)
        this.rowHeight = 60
        this.alwaysBounceVertical = true
        this.separatorStyle = .none
        this.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
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
        tableView.backgroundColor = Asset.Colors.appBackground.color
    }
}

