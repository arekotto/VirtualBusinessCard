//
//  GroupedCardsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 19/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class GroupedCardsVC: AppViewController<GroupedCardsView, GroupedCardsVM> {

    private typealias DataSource = UITableViewDiffableDataSource<GroupedCardsVM.Section, GroupedCardsView.TableCell.DataModel>

    private lazy var collectionViewDataSource = makeTableViewDataSource()

    private lazy var seeAllButton = UIBarButtonItem(title: viewModel.seeAllCardsButtonTitle, style: .plain, target: self, action: #selector(didTapSeeAllButton))

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        setupNavigationItem()
        setupContentView()
        viewModel.delegate = self
        viewModel.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (navigationController as? AppNavigationController)?.isShadowEnabled = false
        contentView.tableView.deselectSelectedRows(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (navigationController as? AppNavigationController)?.isShadowEnabled = true
    }

    private func setupContentView() {
        contentView.tableView.dataSource = collectionViewDataSource
        contentView.tableView.delegate = self
        contentView.scrollableSegmentedControl.delegate = self
        contentView.scrollableSegmentedControl.items = viewModel.availableGroupingModes
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = seeAllButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Edit Tags", comment: ""), style: .plain, target: self, action: #selector(didTapTagsButton))
        navigationItem.searchController = {
            let controller = UISearchController()
            controller.delegate = self
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            return controller
        }()
    }

    private func makeTableViewDataSource() -> DataSource {
        DataSource(tableView: contentView.tableView) { tableView, indexPath, dataModel in
            let cell: GroupedCardsView.TableCell = tableView.dequeueReusableCell(indexPath: indexPath)
            cell.dataModel = dataModel
            return cell
        }
    }
}

extension GroupedCardsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}

// MARK: - Actions

@objc
private extension GroupedCardsVC {
    func didTapSeeAllButton() {
        viewModel.didTapSeeAll()
    }

    func didTapTagsButton() {
        let vc = TagsVC(viewModel: viewModel.tagsVM())
        let navController = AppNavigationController(rootViewController: vc)
        present(navController, animated: true)
    }
}

// MARK: - GroupedCardsVMDelegate
    
extension GroupedCardsVC: GroupedCardsVMDelegate {
    func presentReceivedCards(with viewModel: ReceivedCardsVM) {
        let vc = ReceivedCardsVC(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshData(animated: Bool) {
        seeAllButton.isEnabled = !viewModel.showsEmptyState
        contentView.emptyStateView.isHidden = !viewModel.showsEmptyState
        collectionViewDataSource.apply(viewModel.dataSnapshot(), animatingDifferences: animated)
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

// MARK: - UISearchResultsUpdating

extension GroupedCardsVC: UISearchResultsUpdating, UISearchControllerDelegate {

    func willPresentSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            let frame = self.contentView.scrollableSegmentedControl.frame
            self.contentView.scrollableSegmentedControl.frame = CGRect(origin: frame.origin, size: CGSize(width: frame.size.width, height: 0))
        })
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            let frame = self.contentView.scrollableSegmentedControl.frame
            let newSize = CGSize(width: frame.size.width, height: GroupedCardsView.segmentedControlHeight)
            self.contentView.scrollableSegmentedControl.frame = CGRect(origin: frame.origin, size: newSize)
        })
    }

    func updateSearchResults(for searchController: UISearchController) {
        viewModel.didSearch(for: searchController.searchBar.text ?? "")
    }
}
