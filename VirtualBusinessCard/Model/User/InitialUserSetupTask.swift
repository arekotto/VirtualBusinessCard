//
//  InitialUserSetupTask.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 02/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

protocol SetupTask {
    func run(completion: @escaping (Result<Void, Error>) -> Void)
}
struct InitialUserSetupTask {
    
    struct SetupData {
        let userID: UserID
        let email: String
        let firstName: String
        let lastName: String
    }
    
    enum InitialUserSetupError: Error {
        case userAlreadyExists
        
        var localizedDescription: String {
            "This user already exists."
        }
    }
    
    private struct UserPublicSetupTask: SetupTask {
        let setupData: SetupData
        
        func run(completion: @escaping (Result<Void, Error>) -> Void) {
            let userPublicCollection = Firestore.firestore().collection(UserPublic.collectionName)
            let userPublicDocumentReference = userPublicCollection.document(setupData.userID)
            userPublicDocumentReference.getDocument { result in
                
                switch result {
                case .failure(let err):
                    completion(.failure(err))
                case .success(let snap):
                    guard !snap.exists else {
                        completion(.failure(InitialUserSetupError.userAlreadyExists))
                        return
                    }
                    
                    print(#file, "setting up new public user")
                    
                    let data = self.setupData
                    let newUser = UserPublic(id: data.userID, firstName: data.firstName, lastName: data.lastName, email: data.email)
                    userPublicDocumentReference.setData(newUser.asDocument()) { error in
                        if let err = error {
                            completion(.failure(err))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    private struct UserPrivateSetupTask: SetupTask {
        let setupData: SetupData
        
        func run(completion: @escaping (Result<Void, Error>) -> Void) {
            let userPublicCollection = Firestore.firestore().collection(UserPublic.collectionName)
            let userPublicDocumentReference = userPublicCollection.document(setupData.userID)
            let userPrivateCollection = userPublicDocumentReference.collection(UserPrivate.collectionName)
            let userPrivateDocumentReference = userPrivateCollection.document(UserPrivate.documentName)
            userPrivateDocumentReference.getDocument { result in
                switch result {
                case .failure(let err):
                    completion(.failure(err))
                case .success(let snap):
                    guard !snap.exists else {
                        completion(.failure(InitialUserSetupError.userAlreadyExists))
                        return
                    }
                    
                    print(#file, "setting up new private user")
                    
                    userPrivateDocumentReference.setData(UserPrivate(cardExchangeAccessTokens: []).asDocument()) { error in
                        if let err = error {
                            completion(.failure(err))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    static func run(setupData: SetupData, completion: @escaping (Result<Void, Error>) -> Void) {
        let setupTasks: [SetupTask] = [
            UserPublicSetupTask(setupData: setupData),
            UserPrivateSetupTask(setupData: setupData)
        ]
        
        var encounteredError: Error?
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.notify(queue: .main) {
            if let error = encounteredError {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
        setupTasks.forEach { _ in dispatchGroup.enter() }
        setupTasks.forEach {
            $0.run { result in
                switch result {
                case .failure(let err): encounteredError = err
                case .success: break
                }
                dispatchGroup.leave()
            }
        }
        
    }
}
