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
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController()
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        return controller
    }()
    
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
        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: contentView.cellSizeModeButton)
        contentView.cellSizeModeButton.setImage(viewModel.cellSizeControlImage, for: .normal)
        contentView.cellSizeModeButton.addTarget(self, action: #selector(didTapCellSizeModeButton), for: .touchUpInside)
    }
}

@objc extension ReceivedCardsVC {
    func didTapCellSizeModeButton() {
        viewModel.didChangeCellSizeMode()
    }
}

extension ReceivedCardsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ReceivedCardsView.BusinessCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.setDataModel(viewModel.item(for: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ReceivedCardsView.BusinessCardCell).setSizeMode(viewModel.cellSizeMode)
    }
}

extension ReceivedCardsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ReceivedCardsVC: ReceivedBusinessCardsVMDelegate {
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        let cells = contentView.collectionView.visibleCells as! [ReceivedCardsView.BusinessCardCell]
        cells.forEach { cell in
            cell.updateMotionData(motion, over: timeFrame)
        }
    }
    
    func presentBusinessCardDetails(id: BusinessCardID) {
        
    }
    
    func didUpdateMotionData(motion: CMDeviceMotion) {

    }
    
    func refreshData() {
        contentView.collectionView.reloadData()
    }
    
    func refreshLayout(sizeMode: ReceivedCardsVM.CellSizeMode) {
        contentView.cellSizeModeButton.setImage(viewModel.cellSizeControlImage, for: .normal)
        let layoutFactory = ReceivedCardsView.CollectionViewLayoutFactory(cellSize: sizeMode)
        contentView.collectionView.setCollectionViewLayout(layoutFactory.layout(), animated: true)
        let visibleCells = contentView.collectionView.visibleCells as! [ReceivedCardsView.BusinessCardCell]
        visibleCells.forEach { $0.setSizeMode(sizeMode) }
    }
}

extension ReceivedCardsVC: TabBarDisplayable {
    var tabBarIconImage: UIImage {
        viewModel.tabBarIconImage
    }
}

extension ReceivedCardsVC: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.didSearch(for: searchController.searchBar.text ?? "")
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        viewModel.isSearchActive = true
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.isSearchActive = false
    }
}
