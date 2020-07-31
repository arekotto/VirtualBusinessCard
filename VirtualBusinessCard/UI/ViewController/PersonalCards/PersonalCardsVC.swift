//
//  PersonalCardsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase
import CoreMotion

final class PersonalCardsVC: AppViewController<PersonalCardsView, PersonalCardsVM> {
    
    override init(viewModel: PersonalCardsVM) {
        super.init(viewModel: viewModel)
        title = viewModel.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        setupNavigationItem()
        viewModel.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentView.visibleCells.forEach { $0.setDynamicLightingEnabled(to: true) }
        viewModel.startUpdatingMotionData(in: 0.1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.collectionView.performBatchUpdates({
            self.contentView.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.pauseUpdatingMotionData()
        contentView.visibleCells.forEach { $0.setDynamicLightingEnabled(to: false) }
    }
    
    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: viewModel.newBusinessCardImage, style: .plain, target: self, action: #selector(didTapNewBusinessCardButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: viewModel.settingsImage, style: .plain, target: self, action: #selector(didTapSettingsButton))
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension PersonalCardsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PersonalCardsView.CollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.setDataModel(viewModel.item(for: indexPath))
        cell.shareButton.indexPath = indexPath
        cell.shareButton.addTarget(self, action: #selector(didTapShareButton(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}

// MARK: - Actions

@objc
private extension PersonalCardsVC {
    func didTapNewBusinessCardButton() {
        let navVC = AppNavigationController(rootViewController: EditCardVC(viewModel: viewModel.newCardViewModel()))
        present(navVC, animated: true)
    }
    
    func didTapSettingsButton() {
        show(SettingsVC(viewModel: viewModel.settingsViewModel()), sender: nil)
    }
    
    func didTapShareButton(_ button: PersonalCardsView.CollectionCell.ShareButton) {
        guard let indexPath = button.indexPath else { return }
        let navVC = AppNavigationController(rootViewController: DirectSharingVC(viewModel: viewModel.sharingViewModel(for: indexPath)))
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
}

// MARK: - PersonalCardsVMlDelegate

extension PersonalCardsVC: PersonalCardsVMlDelegate {

    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        let cells = contentView.collectionView.visibleCells as! [PersonalCardsView.CollectionCell]
        cells.forEach { cell in
            cell.updateMotionData(motion, over: timeFrame)
        }
    }
    
    func presentCardDetails(viewModel: CardDetailsVM) {
        show(CardDetailsVC(viewModel: viewModel), sender: nil)
    }
    
    func reloadData() {
        let cv = contentView.collectionView
        cv.reloadData()
        cv.performBatchUpdates({cv.collectionViewLayout.invalidateLayout()})
    }
    
    func presentUserSetup(userID: String, email: String) {
        let vc = UserSetupHC(userID: userID, email: email)
        vc.isModalInPresentation = true
        present(vc, animated: true)
    }
}

extension PersonalCardsVC: TabBarDisplayable {
    var tabBarIconImage: UIImage { viewModel.tabBarIconImage }
}
