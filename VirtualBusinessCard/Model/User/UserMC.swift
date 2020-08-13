//
//  UserMC.swift
//  BillShare
//
//  Created by Arek Otto on 07/04/2019.
//  Copyright © 2019 Arek Otto. All rights reserved.
//

import Firebase

class UserMC {
    
    typealias Model = UserPublic
    
    private var userPublic: UserPublic
    private var userPrivate: UserPrivate?

    var id: UserID { userPublic.id }
    
    var firstName: String {
        get { userPublic.firstName }
        set { userPublic.firstName = newValue }
    }
    
    var lastName: String {
        get { userPublic.lastName }
        set { userPublic.lastName = newValue }
    }
    
    var email: String {
        get { userPublic.email }
        set { userPublic.email = newValue }
    }
    
    var cardExchangeAccessTokens: [String] {
        get { userPrivate?.cardExchangeAccessTokens ?? [] }
        set { userPrivate?.cardExchangeAccessTokens = newValue }
    }

    func committedExchanges(for cardID: BusinessCardID) -> [DirectCardExchangeID] {
        userPrivate?.sharedPersonalCards[cardID] ?? []
    }

    var containsPrivateData: Bool {
        userPrivate != nil
    }
    
    init(userPublic: UserPublic, userPrivate: UserPrivate? = nil) {
        self.userPublic = userPublic
        self.userPrivate = userPrivate
    }
    
    func isModelEqual(to user: UserPublic) -> Bool {
        return self.userPublic == user
    }
    
    func publicAsDocument() -> [String: Any] {
        userPublic.asDocument()
    }

    func privateAsDocument() -> [String: Any]? {
        userPrivate?.asDocument()
    }
    
    func addCardExchangeAccessToken(_ token: String) {
        userPrivate?.cardExchangeAccessTokens.append(token)
    }

    func addExchange(id exchangeID: DirectCardExchangeID, toCardID cardID: BusinessCardID) {
        if let existingExchanges = userPrivate?.sharedPersonalCards[cardID] {
            userPrivate?.sharedPersonalCards[cardID] = existingExchanges + [exchangeID]
        } else {
            userPrivate?.sharedPersonalCards[cardID] = [exchangeID]
        }
    }
}

// MARK: - Extensions for Firebase

extension UserMC {
    convenience init?(userPublicDocument: DocumentSnapshot, userPrivateDocument: DocumentSnapshot? = nil) {
        guard let user = UserPublic(documentSnapshot: userPublicDocument) else { return nil }
        let privateData = userPrivateDocument != nil ? UserPrivate(documentSnapshot: userPrivateDocument!) : nil
        self.init(userPublic: user, userPrivate: privateData)
    }
    
    func setUserPrivate(document: DocumentSnapshot) {
        userPrivate = UserPrivate(documentSnapshot: document)
    }
}

// MARK: - Saving

extension UserMC {
    
    private var userReference: DocumentReference {
        Firestore.firestore().collection(UserPublic.collectionName).document(userPublic.id)
    }
    
    private var privateDataReference: DocumentReference {
        userReference.collection(UserPrivate.collectionName).document(UserPrivate.documentName)
    }

    func save(using transaction: Transaction) {
        transaction.updateData(userPublic.asDocument(), forDocument: userReference)
        if let privateDocument = userPrivate?.asDocument() {
            transaction.updateData(privateDocument, forDocument: privateDataReference)
        }
    }
    
    func save(completion: ((Result<Void, Error>) -> Void)? = nil) {
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        var encounteredError: Error?
        
        userReference.setData(userPublic.asDocument()) { error in
            if encounteredError == nil {
                encounteredError = error
            }
            dispatchGroup.leave()
        }
        if let data = userPrivate {
            privateDataReference.setData(data.asDocument()) { error in
                if encounteredError == nil {
                    encounteredError = error
                }
                dispatchGroup.leave()
            }
        } else {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if let error = encounteredError {
                completion?(.failure(error))
            } else {
                completion?(.success(()))
            }
        }
    }
}
