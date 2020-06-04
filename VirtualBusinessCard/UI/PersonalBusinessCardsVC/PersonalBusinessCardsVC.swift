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

extension PersonalBusinessCardsVC: PersonalBusinessCardsVMlDelegate {
    func presentUserSetup(userID: String, email: String) {
        let vc = UserSetupHC(userID: userID, email: email)
        vc.isModalInPresentation = true
        present(vc, animated: true)
    }
    
    
}
