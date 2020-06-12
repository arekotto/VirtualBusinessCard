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
    
//    let newBusinessCardButton: UIBarButtonItem = {
//        let item = UIBarButtonItem(image: , style: .plain, target: self, action: #selector(didTapNewBusinessCardButton))
//
//        }()

    
    let newBusinessCardButton: UIBarButtonItem = {
        let button = UIButton(type: .system)
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium, scale: .large)
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: imgConfig), for: .normal)
        let buttonItem = UIBarButtonItem(customView: button)
        button.constrainHeight(constant: 32)
        button.constrainWidth(constant: 32)
        button.addTarget(self, action: #selector(didTapNewBusinessCardButton), for: .touchUpInside)
        return buttonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        title = viewModel.title
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = newBusinessCardButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        newBusinessCardButton.customView?.tintColor = UIColor.appAccent
        contentView.collectionView.performBatchUpdates({
            self.contentView.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)

    }
    
    var indexOfCellBeforeDragging = 0
}

@objc
extension PersonalBusinessCardsVC {
    func didTapNewBusinessCardButton() {
        
    }
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
