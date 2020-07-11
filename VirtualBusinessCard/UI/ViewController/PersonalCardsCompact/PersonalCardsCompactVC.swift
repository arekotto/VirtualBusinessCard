//
//  PersonalCardsCompactVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import CoreMotion

final class PersonalCardsCompactVC: AppViewController<PersonalCardsCompactView, PersonalCardsVM> {

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

    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: viewModel.newBusinessCardImage, style: .plain, target: self, action: #selector(didTapNewBusinessCardButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: viewModel.settingsImage, style: .plain, target: self, action: #selector(didTapSettingsButton))
    }
}

@objc
extension PersonalCardsCompactVC {
    func didTapNewBusinessCardButton() {

    }

    func didTapSettingsButton() {
        viewModel.didTapSettings()
    }
}

extension PersonalCardsCompactVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PersonalCardsCompactView.CollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
//        cell.setDataModel(viewModel.item(for: indexPath))
        cell.tag = indexPath.item
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}

extension PersonalCardsCompactVC: PersonalCardsVMlDelegate {
    func presentSettings(viewModel: SettingsVM) {
        let vc = SettingsVC(viewModel: viewModel)
        show(vc, sender: nil)
    }

    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        let cells = contentView.collectionView.visibleCells as! [PersonalCardsCompactView.CollectionCell]
        cells.forEach { cell in
//            cell.updateMotionData(motion, over: timeFrame)
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

extension PersonalCardsCompactVC: TabBarDisplayable {
    var tabBarIconImage: UIImage { viewModel.tabBarIconImage }
}
