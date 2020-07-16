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
    var sharingUserCardData: BusinessCardData

    var receivingUserCardID: BusinessCardID?
    var receivingUserID: UserID?
    var receivingUserCardData: BusinessCardData?
    
    init(id: DirectCardExchangeID, accessToken: String, sharingUserID: UserID, sharingUserCardID: BusinessCardID, sharingUserCardData: BusinessCardData, receivingUserCardID: BusinessCardID? = nil, receivingUserID: UserID? = nil, receivingUserCardData: BusinessCardData? = nil) {
        self.id = id
        self.accessToken = accessToken
        self.sharingUserID = sharingUserID
        self.sharingUserCardID = sharingUserCardID
        self.sharingUserCardData = sharingUserCardData
        self.receivingUserCardID = receivingUserCardID
        self.receivingUserID = receivingUserID
        self.receivingUserCardData = receivingUserCardData
    }
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
