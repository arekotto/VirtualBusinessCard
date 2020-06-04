//
//  FIRDocumentReference.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

extension DocumentReference {
    
    func getDocument(_ completion: @escaping (Result<DocumentSnapshot, Error>) -> Void) {
        getDocument { snapshot, error in
            if let err = error {
                completion(.failure(err))
            } else if let snap = snapshot {
                completion(.success(snap))
            } else {
                completion(.failure(AppError.unknown))
            }
        }
    }
    
}
