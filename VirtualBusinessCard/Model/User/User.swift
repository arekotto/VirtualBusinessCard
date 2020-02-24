//
//  User.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 20/02/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

struct User: Codable {

    /// Corresponds and is equal to the uid property of the user object used by Firebase Auth.
    let id: String
    

    init(id: String) {
        self.id = id
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

