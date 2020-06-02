//
//  PersonalBusinessCardsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

protocol PersonalBusinessCardsVMlDelegate: class {
    func presentUserSetup(_ userID: String)
}

final class PersonalBusinessCardsVM: AppViewModel {
    
    weak var delegate: PersonalBusinessCardsVMlDelegate?
    
    var userID: UserID?
    
    func fetchData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        self.userID = userID
        let userCollection = Firestore.firestore().collection(User.collectionName)
        let userDoc = userCollection.document(userID)
        userDoc.addSnapshotListener(userHasChanged)
    }
    
    private func userHasChanged(_ doc: DocumentSnapshot?, _ error: Error?) {
        guard let userID = userID else { return }
        
        if let error = error {
            // TODO HANDLE ERROR
            print(#file, error.localizedDescription)
        } else {
            guard doc!.exists else {
                delegate?.presentUserSetup(userID)
                return
            }
//            guard let userData = doc?.data() else { return }
//            guard let json = try? JSONSerialization.data(withJSONObject: userData) else { return }
//            guard let user = try? JSONDecoder().decode(User.self, from: json) else { return }
//            self.user = user
//            user.eventIds.forEach { id in
//                eventCollection.document(id).addSnapshotListener(eventHasChanged)
//            }
        }
    }
    
}
