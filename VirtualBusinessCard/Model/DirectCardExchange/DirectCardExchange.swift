//
//  CardExchange.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 13/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

typealias DirectCardExchangeID = String

struct DirectCardExchange: Codable {
    
    var id: DirectCardExchangeID
    var accessToken: String
    
    var sharingUserID: UserID
    var sharingUserCardID: BusinessCardID
    var sharingUserCardData: [BusinessCardData]

    var receivingUserCardID: BusinessCardID?
    var receivingUserID: UserID?
    var receivingUserCardData: [BusinessCardData]?
}

// MARK: - Equatable

extension DirectCardExchange: Equatable {
    static func == (lhs: DirectCardExchange, rhs: DirectCardExchange) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Firestoreable

extension DirectCardExchange: Firestoreable {
    
}

// MARK: - CodingKeys

extension DirectCardExchange {
    enum CodingKeys: String, CodingKey {
        case id, accessToken, sharingUserID, sharingUserCardID, sharingUserCardData, receivingUserCardID, receivingUserID, receivingUserCardData
    }
}
