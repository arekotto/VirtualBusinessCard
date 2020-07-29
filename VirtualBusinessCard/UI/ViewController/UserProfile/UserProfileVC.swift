//
//  UserProfileVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 28/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class UserProfileVC: AppViewController<UserProfileView, UserProfileVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        viewModel.delegate = self
        contentView.collectionView.dataSource = self
        contentView.collectionView.delegate = self
        setupNavigationItem()
        viewModel.fetchData()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
    }
}

extension UserProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TitleValueCollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.setDataModel(viewModel.itemForRow(at: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell: RoundedCollectionCell = collectionView.dequeueReusableSupplementaryView(elementKind: kind, indexPath: indexPath)
        switch UserProfileView.SupplementaryElementKind(rawValue: kind)! {
        case .header: cell.configureRoundedCorners(mode: .top)
        case .footer: cell.configureRoundedCorners(mode: .bottom)
        }
        return cell
    }
}

extension UserProfileVC: UserProfileVMDelegate {
    func presentAlert(title: String?, message: String?) {
        let alert = AppAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(alert, animated: true)
    }
    
    func presentAlertWithTextField(title: String?, message: String?, for row: UserProfileVM.Row) {
        let alert = AppAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = title
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            self.viewModel.didSetNewValue(alert.textFields?.first?.text ?? "", for: row)
        })
        alert.addCancelAction()
        present(alert, animated: true)
    }
    
    func reloadData() {
        contentView.collectionView.reloadData()
    }
}
