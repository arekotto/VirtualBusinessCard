//
//  PersonalBusinessCardsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase
import CoreMotion

final class PersonalBusinessCardsVC: AppViewController<PersonalBusinessCardsView, PersonalBusinessCardsVM> {
    
    override init(viewModel: PersonalBusinessCardsVM) {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.appAccent
        contentView.collectionView.performBatchUpdates({
            self.contentView.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: viewModel.newBusinessCardImage, style: .plain, target: self, action: #selector(didTapNewBusinessCardButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(testingAdd))
    }
}

@objc
extension PersonalBusinessCardsVC {
    func didTapNewBusinessCardButton() {
        
    }
    
    func testingAdd() {
        let task = SampleBCUploadTask()
        task() {_ in }
    }
}

extension PersonalBusinessCardsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PersonalBusinessCardsView.BusinessCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.setDataModel(viewModel.item(for: indexPath))
        cell.tag = indexPath.item
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}

extension PersonalBusinessCardsVC: PersonalBusinessCardsVMlDelegate {
    func didUpdateMotionData(_ motion: CMDeviceMotion, over timeFrame: TimeInterval) {
        let cells = contentView.collectionView.visibleCells as! [PersonalBusinessCardsView.BusinessCardCell]
        cells.forEach { cell in
            cell.updateMotionData(motion, over: timeFrame)
        }
    }
    
    func presentBusinessCardDetails(id: BusinessCardID) {
        show(BusinessCardDetailsVC(viewModel: BusinessCardDetailsVM()), sender: nil)
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

extension PersonalBusinessCardsVC: TabBarDisplayable {
    var tabBarIconImage: UIImage { viewModel.tabBarIconImage }
}
