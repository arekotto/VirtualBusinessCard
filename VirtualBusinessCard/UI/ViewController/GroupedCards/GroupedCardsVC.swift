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
        extendedLayoutIncludesOpaqueBars = true
        viewModel.delegate = self
        contentView.collectionView.dataSource = self
        contentView.collectionView.delegate = self
        setupNavigationItem()
        viewModel.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (navigationController as? AppNavigationController)?.isShadowEnabled = false
        contentView.collectionView.indexPathsForSelectedItems?.forEach {
            contentView.collectionView.deselectItem(at: $0, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (navigationController as? AppNavigationController)?.isShadowEnabled = true
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: viewModel.seeAllCardsButtonTitle, style: .plain, target: self, action: #selector(didTapSeeAllButton))
        navigationItem.searchController = {
            let controller = UISearchController()
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            return controller
        }()
    }
}

extension GroupedCardsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GroupedCardsView.CollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.setDataModel(viewModel.item(for: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        switch GroupedCardsView.SupplementaryElementKind(rawValue: elementKind)! {
        case .collectionViewHeader: collectionView.bringSubviewToFront(view)
        default: return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch GroupedCardsView.SupplementaryElementKind(rawValue: kind)! {
        case .sectionHeader:
            let cell: RoundedCollectionCell = collectionView.dequeueReusableSupplementaryView(elementKind: kind, indexPath: indexPath)
            cell.configureRoundedCorners(mode: .top)
            return cell
        case .sectionFooter:
            let cell: RoundedCollectionCell = collectionView.dequeueReusableSupplementaryView(elementKind: kind, indexPath: indexPath)
            cell.configureRoundedCorners(mode: .bottom)
            return cell
        case .collectionViewHeader:
            let cell: GroupedCardsView.CollectionHeader = collectionView.dequeueReusableSupplementaryView(elementKind: kind, indexPath: indexPath)
            contentView.scrollableSegmentedControl.removeFromSuperview()
            contentView.scrollableSegmentedControl.delegate = self
            cell.mainStackView.addArrangedSubview(contentView.scrollableSegmentedControl)
            contentView.scrollableSegmentedControl.items = viewModel.availableGroupingModes
            return cell
        }
    }
}

// MARK: - Actions

@objc
private extension GroupedCardsVC {
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
        contentView.collectionView.reloadData()
    }
    
    func refreshData(preUpdateItemCount: Int, postUpdateItemCount: Int, animated: Bool) {
        if animated {
            refreshData(preUpdateItemCount: preUpdateItemCount, postUpdateItemCount: postUpdateItemCount)
        } else {
            UIView.performWithoutAnimation {
                refreshData(preUpdateItemCount: preUpdateItemCount, postUpdateItemCount: postUpdateItemCount)
            }
        }
    }
    
    private func refreshData(preUpdateItemCount: Int, postUpdateItemCount: Int) {
        let cv = contentView.collectionView
        cv.performBatchUpdates({
            if preUpdateItemCount == postUpdateItemCount {
                cv.reloadItems(at: Array(0..<preUpdateItemCount).map { IndexPath(item: $0) })
            } else if preUpdateItemCount < postUpdateItemCount {
                cv.reloadItems(at: Array(0..<preUpdateItemCount).map { IndexPath(item: $0) })
                cv.insertItems(at: Array(preUpdateItemCount..<postUpdateItemCount).map { IndexPath(item: $0) })
            } else {
                cv.reloadItems(at: Array(0..<postUpdateItemCount).map { IndexPath(item: $0) })
                cv.deleteItems(at: Array(postUpdateItemCount..<preUpdateItemCount).map { IndexPath(item: $0) })
            }
        })
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

extension GroupedCardsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.didSearch(for: searchController.searchBar.text ?? "")
    }
}
