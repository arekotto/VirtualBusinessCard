//
//  Firestoreable.swift
//  BillShare
//
//  Created by Arek Otto on 22/02/2019.
//  Copyright © 2019 Arek Otto. All rights reserved.
//

import Firebase

protocol DocumentRepresentable: Codable {
    func asDocument() -> [String: Any]
}

extension DocumentRepresentable {
    func asDocument() -> [String: Any] {
        guard let json = try? JSONEncoder().encode(self) else {
            return [:]
        }
        
        return ((try? JSONSerialization.jsonObject(with: json)) as? [String: Any]) ?? [:]
    }
}

protocol Firestoreable: DocumentRepresentable, Equatable {
    static var collectionName: String { get }
}

extension Firestoreable {
    
    init?(queryDocumentSnapshot: QueryDocumentSnapshot) {
        self.init(dictionary: queryDocumentSnapshot.data())
    }
    
    init?(documentSnapshot: DocumentSnapshot) {
        guard let userData = documentSnapshot.data() else { return nil }
        self.init(dictionary: userData)
    }
    
    init?(dictionary: [String: Any]) {
        guard let json = try? JSONSerialization.data(withJSONObject: dictionary) else { return nil}
        guard let decodedBusinessCard = try? JSONDecoder().decode(Self.self, from: json) else { return nil }
        self = decodedBusinessCard
    }
}

extension Firestoreable {
    static var collectionName: String { String(describing: self) }
}
