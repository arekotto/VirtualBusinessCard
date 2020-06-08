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

final class PersonalBusinessCardsVC: AppViewController<PersonalBusinessCardsView, PersonalBusinessCardsVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.fetchData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "logout", style: .done, target: self, action: #selector(logout))
    }
    
    @objc func logout() {
        try! Auth.auth().signOut()
    }
    
}

extension PersonalBusinessCardsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PersonalBusinessCardsView.BusinessCardCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.dataModel = viewModel.itemAt(for: indexPath)
        return cell
    }
    
    
}

extension PersonalBusinessCardsVC: PersonalBusinessCardsVMlDelegate {
    func reloadData() {
        contentView.collectionView.reloadData()
    }
    
    func presentUserSetup(userID: String, email: String) {
        let vc = UserSetupHC(userID: userID, email: email)
        vc.isModalInPresentation = true
        present(vc, animated: true)
    }
    
    
}
