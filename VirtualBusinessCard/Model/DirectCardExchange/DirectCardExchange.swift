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
    var sharingUserCardLocalizations: [BusinessCardLocalization]
    var sharingUserMostRecentUpdate: Date

    var receivingUserCardID: BusinessCardID?
    var receivingUserID: UserID?
    var receivingUserCardLocalizations: [BusinessCardLocalization]?
    var receivingUserMostRecentUpdate: Date?
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
        case id
        case accessToken
        case sharingUserID
        case sharingUserCardID
        case sharingUserCardLocalizations
        case sharingUserMostRecentUpdate
        case receivingUserCardID
        case receivingUserID
        case receivingUserCardLocalizations
        case receivingUserMostRecentUpdate
    }
}
