//
//  UserPrivate.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 04/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

struct UserPrivate: Codable {

    var personalBusinessCardIDs: [BusinessCardID]
    var collectedBusinessCardIDs: [BusinessCardID]
    
    init(personalBusinessCardIDs: [BusinessCardID] = [], collectedBusinessCardIDs: [BusinessCardID] = []) {
        self.personalBusinessCardIDs = personalBusinessCardIDs
        self.collectedBusinessCardIDs = collectedBusinessCardIDs
    }
}

extension UserPrivate: SingletonFirestoreable {
    static var documentName: String {
        "private_data"
    }
}
