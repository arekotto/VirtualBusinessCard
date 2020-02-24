//
//  Firestoreable.swift
//  BillShare
//
//  Created by Arek Otto on 22/02/2019.
//  Copyright © 2019 Arek Otto. All rights reserved.
//

import Foundation

protocol Firestoreable: Codable, Equatable {
    static var collectionName: String {get}
}

extension Firestoreable {
    func asDocument() -> [String: Any] {
        guard let json = try? JSONEncoder().encode(self) else {
            return [:]
        }

        return ((try? JSONSerialization.jsonObject(with: json)) as? [String: Any]) ?? [:]
    }
}
