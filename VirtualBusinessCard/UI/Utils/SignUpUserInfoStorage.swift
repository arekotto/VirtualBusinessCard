//
//  SignUpUserInfoStorage.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 04/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

final class SignUpUserInfoStorage {
    
    static var shared = SignUpUserInfoStorage()
    
    private let userDefaults = UserDefaults()
    
    private init(){}
    
    func storeInfo(firstName: String, lastName: String) {
        userDefaults.set(firstName, forKey: StorageKey.signUpUserInfoFirstName.rawValue)
        userDefaults.set(lastName, forKey: StorageKey.signUpUserInfoLastName.rawValue)
    }
    
    func getInfo() -> (firstName: String?, lastName: String?) {
        (userDefaults.string(forKey: StorageKey.signUpUserInfoLastName.rawValue), userDefaults.string(forKey: StorageKey.signUpUserInfoLastName.rawValue))
    }
    
    func removeAll() {
        StorageKey.allCases.forEach {
            userDefaults.removeObject(forKey: $0.rawValue)
        }
    }
    
    private enum StorageKey: String, CaseIterable {
        case signUpUserInfoFirstName, signUpUserInfoLastName
    }
}
