//
//  AppViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation
import Firebase

class AppViewModel {
    
    private static let sharedDataBase = Firestore.firestore()
    
    final let userID: UserID

    init(userID: UserID) {
        self.userID = userID
    }
    
    final var db: Firestore {
        Self.sharedDataBase
    }

    final var userPublicDocumentReference: DocumentReference {
        Self.sharedDataBase.collection(UserPublic.collectionName).document(userID)
    }
}
