//
//  SettingsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

protocol SettingsVMDelegate: class {
    
}

final class SettingsVM: AppViewModel {
    
    weak var delegate: SettingsVMDelegate?
 
    func logout() {
        try! Auth.auth().signOut()
    }
    
}
