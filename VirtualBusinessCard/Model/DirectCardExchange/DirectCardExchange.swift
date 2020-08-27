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
    
    var ownerID: UserID
    var ownerCardID: BusinessCardID
    var ownerCardLocalizations: [BusinessCardLocalization]
    var ownerCardVersion: Int

    var guestCardID: BusinessCardID?
    var guestID: UserID?
    var guestCardLocalizations: [BusinessCardLocalization]?
    var guestCardVersion: Int
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

        case ownerID
        case ownerCardID
        case ownerCardLocalizations
        case ownerCardVersion

        case guestCardID
        case guestID
        case guestCardLocalizations
        case guestCardVersion
    }
}
