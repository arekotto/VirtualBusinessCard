//
//  GroupedCardsView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 21/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class GroupedCardsView: AppBackgroundView {
    let scrollableSegmentedControl = ScrollableSegmentedControl()
    
    let tableView: UITableView = {
        let this = UITableView()
        this.backgroundColor = nil
        return this
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        [scrollableSegmentedControl, tableView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        scrollableSegmentedControl.constrainTopToSuperview()
        scrollableSegmentedControl.constrainHorizontallyToSuperview()
        scrollableSegmentedControl.constrainHeight(constant: 50)
        
        tableView.constrainTop(to: scrollableSegmentedControl.bottomAnchor)
        tableView.constrainHorizontallyToSuperview()
        tableView.constrainBottomToSuperview()
    }
}

extension GroupedCardsView {
    class TableCell: AppTableViewCell {
        
    }
}
