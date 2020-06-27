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
        contentView.scrollableSegmentedControl.items = viewModel.availableGroupingModes
        contentView.scrollableSegmentedControl.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        setupNavigationItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchData()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: viewModel.seeAllCardsButtonTitle, style: .plain, target: self, action: #selector(didTapSeeAllButton))
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension GroupedCardsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupedCardsView.TableCell = tableView.dequeueReusableCell(indexPath: indexPath)
        cell.setDataModel(viewModel.item(for: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        contentView.scrollableSegmentedControl
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1

        let tableCell = cell as! GroupedCardsView.TableCell
        if isFirst && isLast {
            tableCell.setRoundedCornersMode(.all)
        } else if isFirst {
            tableCell.setRoundedCornersMode(.top)
        } else if isLast {
            tableCell.setRoundedCornersMode(.bottom)
        } else {
            tableCell.setRoundedCornersMode(.none)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}

// MARK: - Actions

@objc private extension GroupedCardsVC {
    func didTapSeeAllButton() {
        viewModel.didTapSeeAll()
    }
}

// MARK: - GroupedCardsVMDelegate
    
extension GroupedCardsVC: GroupedCardsVMDelegate {
    func presentReceivedCards(with viewModel: ReceivedCardsVM) {
        let vc = ReceivedCardsVC(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func refreshData() {
        contentView.tableView.reloadData()
    }
}

// MARK: - TabBarDisplayable

extension GroupedCardsVC: TabBarDisplayable {
    var tabBarIconImage: UIImage {
        viewModel.tabBarIconImage
    }
}

// MARK: - ScrollableSegmentedControlDelegate

extension GroupedCardsVC: ScrollableSegmentedControlDelegate {
    func scrollableSegmentedControl(_ control: ScrollableSegmentedControl, didSelectItemAt index: Int) {
        viewModel.didSelectGroupingMode(at: index)
    }
}
