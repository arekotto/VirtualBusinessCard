//
//  InitialUserSetupTask.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 02/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

struct InitialUserSetupTask {
    
    static func run(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        let collection = Firestore.firestore().collection(User.collectionName)
        let doc = collection.document(userId)
        doc.getDocument { result in
            switch result {
            case .failure(let err): completion(.failure(err))
            case .success(let snap):
                print(#file, "setting up new user")
                let newUser = User(id: userId)
                doc.setData(newUser.asDocument())
                completion(.success(newUser))
            }
        }
    }
}
