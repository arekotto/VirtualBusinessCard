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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupCollectionView()
        setupNavigationItem()
        extendedLayoutIncludesOpaqueBars = true
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchData()
    }
    
    private func setupCollectionView() {
        let layoutFactory = ReceivedCardsView.CollectionViewLayoutFactory(cellSize: viewModel.cellSizeMode)
        contentView.collectionView.setCollectionViewLayout(layoutFactory.layout(), animated: false)
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: contentView.cellSizeModeButton)
        contentView.cellSizeModeButton.setImage(viewModel.cellSizeControlImage, for: .normal)
        contentView.cellSizeModeButton.addTarget(self, action: #selector(didTapCellSizeModeButton), for: .touchUpInside)
        navigationItem.searchController = {
            let controller = UISearchController()
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            return controller
        }()
    }
}

// MARK: - Actions

@objc extension ReceivedCardsVC {
    func didTapCellSizeModeButton() {
        viewModel.didChangeCellSizeMode()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension ReceivedCardsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ReceivedCardsView.CollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.cardFrontBackView.setDataModel(viewModel.item(for: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ReceivedCardsView.CollectionCell).cardFrontBackView.setSizeMode(viewModel.cellSizeMode)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}

// MARK: ReceivedBusinessCardsVMDelegate

extension ReceivedCardsVC: ReceivedBusinessCardsVMDelegate {
    func presentCardDetails(viewModel: CardDetailsVM) {
        show(CardDetailsVC(viewModel: viewModel), sender: nil)
    }
    
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        let cells = contentView.collectionView.visibleCells as! [ReceivedCardsView.CollectionCell]
        cells.forEach { cell in
            cell.cardFrontBackView.updateMotionData(motion, over: timeFrame)
        }
    }
    
    func refreshData() {
        contentView.collectionView.reloadData()
    }
    
    func refreshLayout(sizeMode: CardFrontBackView.SizeMode) {
        contentView.cellSizeModeButton.setImage(viewModel.cellSizeControlImage, for: .normal)
        let layoutFactory = ReceivedCardsView.CollectionViewLayoutFactory(cellSize: sizeMode)
        contentView.collectionView.setCollectionViewLayout(layoutFactory.layout(), animated: true)
        let visibleCells = contentView.collectionView.visibleCells as! [ReceivedCardsView.CollectionCell]
        visibleCells.forEach { $0.cardFrontBackView.setSizeMode(sizeMode) }
    }
}

// MARK: - TabBarDisplayable

extension ReceivedCardsVC: TabBarDisplayable {
    var tabBarIconImage: UIImage {
        viewModel.tabBarIconImage
    }
}

// MARK: - UISearchResultsUpdating, UISearchControllerDelegate

extension ReceivedCardsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.didSearch(for: searchController.searchBar.text ?? "")
    }
}
