//
//  UserManager.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

//class UserManager {
//
//    static var shared = UserManager()
//
//    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
//
//    private init() {}
//
//    func configure() {
//        authStateListenerHandle = Auth.auth().addStateDidChangeListener(authStateDidChange)
//    }
//
//    private func authStateDidChange(_ auth: Auth?, _ user: Firebase.User?) {
//        if let userID = user?.uid {
//            let collection = Firestore.firestore().collection(User.collectionName)
//
//            let doc = collection.document(userID)
//            doc.getDocument { result in
//                switch result {
//                case .failure(_): completion(.unknown)
//                case .success(let snap):
//                    snap.exists ? completion(.completed) : completion(.uncompleted)
//                }
//            }
//        } else {
//        }
//    }
//}
