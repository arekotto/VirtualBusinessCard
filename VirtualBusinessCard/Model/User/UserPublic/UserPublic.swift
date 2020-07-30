//
//  UserPublic.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 20/02/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

typealias UserID = String

struct UserPublic: Codable {

    /// Corresponds and is equal to the uid property of the user object used by Firebase Auth.
    let id: UserID
    var firstName: String
    var lastName: String
    var email: String
    var profileImageURL: URL?

    init(id: UserID, firstName: String, lastName: String, email: String, profileImageURL: URL? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profileImageURL = profileImageURL
    }
}

extension UserPublic: Equatable {
    static func == (lhs: UserPublic, rhs: UserPublic) -> Bool {
        return lhs.id == rhs.id
    }
}
