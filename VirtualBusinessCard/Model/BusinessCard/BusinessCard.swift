//
//  BusinessCard.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 04/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

typealias BusinessCardID = String

struct BusinessCard: Codable {

    let id: BusinessCardID
    
    init(id: BusinessCardID) {
        self.id = id
    }
}

extension BusinessCard: Equatable {
    static func == (lhs: BusinessCard, rhs: BusinessCard) -> Bool {
        return lhs.id == rhs.id
    }
}
