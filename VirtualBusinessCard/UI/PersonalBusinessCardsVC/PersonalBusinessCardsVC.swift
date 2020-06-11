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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        title = viewModel.title
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.collectionView.performBatchUpdates({
            self.contentView.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)

    }
    
    var indexOfCellBeforeDragging = 0
}

extension PersonalBusinessCardsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PersonalBusinessCardsView.BusinessCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.setDataModel(viewModel.itemAt(for: indexPath))
        return cell
    }
}

extension PersonalBusinessCardsVC: PersonalBusinessCardsVMlDelegate {
    func didUpdateMotionData(motion: CMDeviceMotion) {
        (contentView.collectionView.visibleCells as? [PersonalBusinessCardsView.BusinessCardCell])?.forEach { cell in
            cell.updateMotionData(motion)
        }
    }
    
    func reloadData() {
        contentView.collectionView.reloadData()
    }
    
    func presentUserSetup(userID: String, email: String) {
        let vc = UserSetupHC(userID: userID, email: email)
        vc.isModalInPresentation = true
        present(vc, animated: true)
    }
}
