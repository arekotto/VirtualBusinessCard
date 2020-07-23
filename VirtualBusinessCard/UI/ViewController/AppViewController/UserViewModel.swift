//
//  UserViewModel.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 23/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

class UserViewModel: AppViewModel {

    private(set) var user: UserMC?

    private var userPrivateDocumentReference: DocumentReference {
        userPublicDocumentReference.collection(UserPrivate.collectionName).document(UserPrivate.documentName)
    }

    func fetchData() {
        userPublicDocumentReference.addSnapshotListener() { [weak self] document, error in
            self?.userPublicDidChange(document, error)
        }
    }

    func informDelegateAboutDataRefresh() {
        // override this method
    }

    private func userPublicDidChange(_ document: DocumentSnapshot?, _ error: Error?) {

        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching user public changed:", error?.localizedDescription ?? "No error info available.")
            return
        }

        guard let user = UserMC(userPublicDocument: doc) else {
            print(#file, "Error mapping user public:", doc.documentID)
            return
        }
        self.user = user
        userPrivateDocumentReference.addSnapshotListener() { [weak self] snapshot, error in
            self?.userPrivateDidChange(snapshot, error)
        }
    }

    private func userPrivateDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching user private changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        user?.setUserPrivate(document: doc)
        informDelegateAboutDataRefresh()
    }
}
