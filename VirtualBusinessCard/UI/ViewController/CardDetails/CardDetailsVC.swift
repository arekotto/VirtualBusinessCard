//
//  CardDetailsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class CardDetailsVC: AppViewController<CardDetailsView, CardDetailsVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        viewModel.delegate = self
        viewModel.fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (contentView.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CardDetailsView.CardImagesCell)?.extendWithAnimation()
    }
    
    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
    }
}

extension CardDetailsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOrSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.row(at: indexPath) {
        case .dataCell(let dataModel):
            let cell: TitleValueCollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.setDataModel(dataModel)
            return cell
        case .cardImagesCell(let dataModel):
            let cell: CardDetailsView.CardImagesCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.cardFrontBackView.setDataModel(dataModel)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell: RoundedCollectionCell = collectionView.dequeueReusableSupplementaryView(elementKind: kind, indexPath: indexPath)
        switch UserProfileView.SupplementaryElementKind(rawValue: kind)! {
        case .header: cell.configureRoundedCorners(mode: .top)
        case .footer: cell.configureRoundedCorners(mode: .bottom)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension CardDetailsVC: CardDetailsVMDelegate {
    func reloadData() {
        contentView.collectionView.reloadData()
    }
}
