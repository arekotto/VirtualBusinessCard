//
//  ReceivedCardsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 15/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CoreMotion

final class ReceivedCardsVC: AppViewController<ReceivedCardsView, ReceivedCardsVM> {

    private typealias View = ReceivedCardsView
    private typealias DataSource = UICollectionViewDiffableDataSource<ReceivedCardsVM.Section, View.CollectionCell.DataModel>

    private lazy var collectionViewDataSource = makeTableViewDataSource()

    private var animator: DetailsTransitionAnimator?
    
    var selectedCell: UICollectionViewCell? {
        guard let indexPath = viewModel.presentedIndexPath else { return nil }
        return contentView.collectionView.cellForItem(at: indexPath)
    }

    private var isSearchActive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupCollectionView()
        setupNavigationItem()
        extendedLayoutIncludesOpaqueBars = true
        definesPresentationContext = true
        viewModel.fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startUpdatingMotionData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedCell?.isHidden = false
        viewModel.presentedIndexPath = nil
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.pauseUpdatingMotionData()
    }
    
    private func setupCollectionView() {
        let layoutFactory = View.CollectionViewLayoutFactory(style: viewModel.cellStyle)
        contentView.collectionView.setCollectionViewLayout(layoutFactory.layout(), animated: false)
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = collectionViewDataSource
    }
    
    private func setupNavigationItem() {
        contentView.titleView.tagImageColor = viewModel.titleImageColor
        contentView.titleView.titleLabel.text = viewModel.title
        navigationItem.titleView = contentView.titleView
        navigationItem.largeTitleDisplayMode = .never

        contentView.cellSizeModeButton.setImage(viewModel.cellSizeControlImage, for: .normal)
        contentView.cellSizeModeButton.addTarget(self, action: #selector(didTapCellSizeModeButton), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: contentView.cellSizeModeButton),
            UIBarButtonItem(image: viewModel.sortControlImage, style: .plain, target: self, action: #selector(didTapSortButton))
        ]

        navigationItem.searchController = {
            let controller = UISearchController()
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            return controller
        }()
    }

    private func presentCardDetails(for indexPath: IndexPath) {
        viewModel.presentedIndexPath = indexPath
        let detailsVC = AppNavigationController(rootViewController: CardDetailsVC(viewModel: viewModel.detailsViewModel(for: indexPath)))
        detailsVC.transitioningDelegate = self
        detailsVC.modalPresentationStyle = .fullScreen
        present(detailsVC, animated: true)
    }

    private func makeTableViewDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: contentView.collectionView) { [weak self] collectionView, indexPath, dataModel in
            let cell: View.CollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.setDataModel(dataModel)
            cell.isHidden = self?.viewModel.presentedIndexPath == indexPath
            return cell
        }
        dataSource.supplementaryViewProvider = { [weak self] cv, kind, indexPath in
            let view: View.UpdateAvailableIndicator = cv.dequeueReusableSupplementaryView(elementKind: kind, indexPath: indexPath)
            view.isHidden = !(self?.viewModel.hasUpdatesForCard(at: indexPath) ?? false)
            return view
        }
        return dataSource
    }
}

// MARK: - Actions

@objc
extension ReceivedCardsVC {
    func didTapCellSizeModeButton() {
        viewModel.toggleCellSizeMode()
    }
    
    func didTapSortButton() {
        let dataModel = viewModel.sortingAlertControllerDataModel()
        let alert = AppAlertController(title: dataModel.title, message: nil, preferredStyle: .actionSheet)
        dataModel.actions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: .default) { _ in
                self.viewModel.setSortMode(action.mode)
            }
            alertAction.setValue(action.mode == viewModel.selectedSortMode, forKey: "checked")
            alert.addAction(alertAction)
        }
        alert.addCancelAction()
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension ReceivedCardsVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! View.CollectionCell).cardFrontBackView.style = viewModel.cellStyle
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // turning this off doesn't break anything if everything still works in a week delete this
//        if contentView.collectionView.contentOffset.y < -88 && !(navigationItem.searchController?.isActive ?? false) {
//            contentView.collectionView.scrollToItem(at: IndexPath(item: 0), at: .top, animated: false)
//        }
        presentCardDetails(for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let firstVisibleItem = collectionView.indexPathsForVisibleItems.min() else { return proposedContentOffset }
        let isShowingFirstItem = firstVisibleItem.item == 0
        return isShowingFirstItem ? collectionView.contentOffset : proposedContentOffset
    }
}

// MARK: ReceivedBusinessCardsVMDelegate

extension ReceivedCardsVC: ReceivedBusinessCardsVMDelegate {
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        (contentView.collectionView.visibleCells as! [View.CollectionCell]).forEach { cell in
            cell.cardFrontBackView.updateMotionData(motion, over: timeFrame)
        }
    }

    func refreshUpdateIndicators() {
        let supplementaryViewKind = View.SupplementaryView.updateAvailableIndicator.rawValue
        let supplementaryItemsIndexPaths = contentView.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: supplementaryViewKind)
        supplementaryItemsIndexPaths.forEach {
            contentView.collectionView.supplementaryView(forElementKind: supplementaryViewKind, at: $0)?.isHidden = !viewModel.hasUpdatesForCard(at: $0)
        }
    }
    
    func refreshData(animated: Bool) {
        collectionViewDataSource.apply(viewModel.dataSnapshot(), animatingDifferences: animated)
    }
    
    func refreshLayout(style: CardFrontBackView.Style) {
        contentView.cellSizeModeButton.setImage(viewModel.cellSizeControlImage, for: .normal)
        let layoutFactory = View.CollectionViewLayoutFactory(style: style)
        contentView.collectionView.setCollectionViewLayout(layoutFactory.layout(), animated: true)
        let visibleCells = contentView.collectionView.visibleCells as! [View.CollectionCell]
        visibleCells.forEach { $0.cardFrontBackView.style = style }
    }
}

// MARK: - UISearchResultsUpdating, UISearchControllerDelegate

extension ReceivedCardsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.beginSearch(for: searchController.searchBar.text ?? "")
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ReceivedCardsVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let selectedCell = self.selectedCell else { return nil }
        guard let cellSnap = selectedCell.contentView.snapshotView(afterScreenUpdates: false) else { return nil }

        let searchController = navigationItem.searchController
        let searchBarHeight = searchController?.searchBar.bounds.height ?? 0
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame

        let availableAnimationOriginY = (searchController?.isActive ?? false) ? safeAreaFrame.origin.y : safeAreaFrame.origin.y - searchBarHeight
        let availableAnimationBoundsHeight = (searchController?.isActive ?? false) ? safeAreaFrame.height : safeAreaFrame.height + searchBarHeight

        let availableAnimationBoundsOrigin = CGPoint(x: safeAreaFrame.origin.x, y: availableAnimationOriginY)
        let availableAnimationBoundsSize = CGSize(width: safeAreaFrame.width, height: availableAnimationBoundsHeight)
        animator = DetailsTransitionAnimator(
            type: .present,
            animatedCellSnapshot: cellSnap,
            availableAnimationBounds: CGRect(origin: availableAnimationBoundsOrigin, size: availableAnimationBoundsSize)
        ) { [weak self] in
            self?.selectedCell
        }
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator?.type = .dismiss
        return animator
    }
}
