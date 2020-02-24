//
//  User+Firestorable.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 20/02/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation
import Firebase

extension Firestoreable {
    static func initFrom(_ doc: DocumentSnapshot) -> User? {
        guard let userData = doc.data() else { return nil }
        guard let json = try? JSONSerialization.data(withJSONObject: userData) else { return nil}
        return try? JSONDecoder().decode(User.self, from: json)
    }
}

extension User: Firestoreable {
    static var collectionName: String {
        return "users"
    }
    
}
