//
//  GroupedCardsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 21/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Kingfisher

final class GroupedCardsView: AppBackgroundView {

    let scrollableSegmentedControl = ScrollableSegmentedControl()

    let emptyStateView = EmptyStateView(
        title: NSLocalizedString("No Cards to Show", comment: ""),
        subtitle: NSLocalizedString("After you exchange your business card with other users, their cards will appear here.", comment: ""),
        isHidden: true
    )

    private(set) lazy var tableView: UITableView = {
        let this = UITableView(frame: .zero, style: .insetGrouped)
        this.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        this.rowHeight = 110
        this.separatorStyle = .none
        this.registerReusableCell(TableCell.self)
        this.isScrollEnabled = true
        this.alwaysBounceVertical = true
        return this
    }()
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.backgroundColor = Asset.Colors.appBackground.color
        scrollableSegmentedControl.backgroundColor = Asset.Colors.appBackground.color
    }
}
