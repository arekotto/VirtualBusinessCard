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
    var sharingUserCardData: BusinessCardData

    var scanningUserID: UserID?
    var scanningUserCardData: BusinessCardData?
    
    init(id: DirectCardExchangeID, accessToken: String, sharingUserID: UserID, sharingUserCardData: BusinessCardData, scanningUserID: UserID? = nil, scanningUserCardData: BusinessCardData? = nil) {
        self.id = id
        self.accessToken = accessToken
        self.sharingUserID = sharingUserID
        self.sharingUserCardData = sharingUserCardData
        self.scanningUserID = scanningUserID
        self.scanningUserCardData = scanningUserCardData
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
        case id, accessToken, sharingUserCardData, sharingUserID, scanningUserID, scanningUserCardData
    }
}
