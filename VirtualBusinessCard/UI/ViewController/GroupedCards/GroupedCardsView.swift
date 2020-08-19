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

    static let segmentedControlHeight: CGFloat = 58

    private var segmentedControlAppliedInsets: CGFloat = 0
    
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
        scrollableSegmentedControl.frame = CGRect(x: 0, y: 0, width: 0, height: Self.segmentedControlHeight)
        this.tableHeaderView = scrollableSegmentedControl
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
        let layoutInset = layoutMargins.left
        if layoutInset != segmentedControlAppliedInsets {
            segmentedControlAppliedInsets = layoutInset
            scrollableSegmentedControl.setInsets(sideInsets: layoutInset, bottomInset: 8)
        }
    }
}

// MARK: - GroupedCardsView

extension GroupedCardsView {
    enum SupplementaryElementKind: String {
        case collectionViewHeader
        case sectionHeader
        case sectionFooter
    }
}

// MARK: - SegmentedControlHeader

extension GroupedCardsView {
    final class CollectionHeader: AppCollectionViewCell, Reusable {
        
        let mainStackView = UIStackView()
        
        override func layoutSubviews() {
            super.layoutSubviews()
            backgroundColor = Asset.Colors.appBackground.color
        }
        
        override func configureSubviews() {
            super.configureSubviews()
            contentView.addSubview(mainStackView)
        }
        
        override func configureConstraints() {
            super.configureConstraints()
            mainStackView.constrainToEdgesOfSuperview()
        }
    }
}
