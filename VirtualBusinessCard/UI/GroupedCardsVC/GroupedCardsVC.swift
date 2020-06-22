//
//  GroupedCardsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 19/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class GroupedCardsVC: AppViewController<GroupedCardsView, GroupedCardsVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        contentView.scrollableSegmentedControl.items = ["Tag", "Date", "Company"]
        contentView.scrollableSegmentedControl.delegate = self
        setupNavigationItem()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.largeTitleDisplayMode = .always
    }
    
}

extension GroupedCardsVC: GroupedCardsVMDelegate {
    
}

extension GroupedCardsVC: TabBarDisplayable {
    var tabBarIconImage: UIImage {
        viewModel.tabBarIconImage
    }
}

extension GroupedCardsVC: ScrollableSegmentedControlDelegate {
    func scrollableSegmentedControl(_ control: ScrollableSegmentedControl, didSelectItemAt index: Int) {
        print(index)
    }
}
