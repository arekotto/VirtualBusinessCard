//
//  UserMC.swift
//  BillShare
//
//  Created by Arek Otto on 07/04/2019.
//  Copyright © 2019 Arek Otto. All rights reserved.
//

import Firebase

class UserMC: ModelController {
    
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

    var profileImageURL: URL? {
        // TODO: change for real url xD
        return URL(string: "https://www.askideas.com/media/26/Bill-Gates-Funny-Face-Picture.jpeg")
    }
//
//    var personalBusinessCardIDs: [BusinessCardID] { userPrivate?.personalBusinessCardIDs ?? [] }
//
//    var collectedBusinessCardIDs: [BusinessCardID] { userPrivate?.collectedBusinessCardIDs ?? [] }
    
    init(userPublic: UserPublic, userPrivate: UserPrivate? = nil) {
        self.userPublic = userPublic
        self.userPrivate = userPrivate
    }
    
    func isModelEqual(to user: UserPublic) -> Bool {
        return self.userPublic == user
    }
    
    func asDocument() -> [String : Any] {
        return userPublic.asDocument()
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

extension UserMC {
    
    private var userReference: DocumentReference {
        Firestore.firestore().collection(UserPublic.collectionName).document(userPublic.id)
    }
    
    private var privateDataReference: DocumentReference {
        userReference.collection(UserPrivate.collectionName).document(UserPrivate.documentName)
    }
    
    func save() {
        userReference.setData(userPublic.asDocument())
        if let data = userPrivate {
            privateDataReference.setData(data.asDocument())
        }
    }
}



