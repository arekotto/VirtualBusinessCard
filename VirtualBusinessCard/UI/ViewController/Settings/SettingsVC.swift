//
//  SettingsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class SettingsVC: AppViewController<SettingsView, SettingsVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        hidesBottomBarWhenPushed = true
        viewModel.delegate = self
        contentView.collectionView.dataSource = self
        contentView.collectionView.delegate = self
        setupNavigationItem()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Test Data", style: .plain, target: self, action: #selector(testingAdd))
    }
    
    @objc
    func testingAdd() {
        let task = SampleBCUploadTask()
        task() {_ in }
    }
}

extension SettingsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = viewModel.itemForRow(at: indexPath)
        switch item.dataModel {
        case .buttonCell(let title):
            let cell: TitleCollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.setTitle(title, color: .appAccent)
            return cell
        case .accessoryCell(let dataModel):
            let cell: TitleAccessoryImageCollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.setDataModel(dataModel)
            return cell
        }

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

extension SettingsVC: SettingsVMDelegate {
    func presentLogoutAlertController(title: String, actionTitle: String) {
        let alert = UIAlertController.accentTinted(title: title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive) { _ in
            self.viewModel.didSelectLogoutAction()
        })
        alert.addCancelAction()
        present(alert, animated: true)
    }
    
    func presentUserProfileVC(with viewModel: UserProfileVM) {
        show(UserProfileVC(viewModel: viewModel), sender: nil)
    }
    
    func presentTagsVC(with viewModel: TagsVM) {
        show(TagsVC(viewModel: viewModel), sender: nil)
    }
}
