//
//  ReceivedBusinessCard.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 15/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

struct ReceivedBusinessCard {
    var id: BusinessCardID
    var exchangeID: DirectCardExchangeID
    var originalID: BusinessCardID
    var ownerID: UserID
    var receivingDate: Date
    var mostRecentUpdateDate: Date
    var localizations: [BusinessCardLocalization]
    var tagIDs: [BusinessCardTagID]
    var notes: String
    
    init(id: BusinessCardID,
         exchangeID: DirectCardExchangeID,
         originalID: BusinessCardID,
         ownerID: UserID,
         receivingDate: Date,
         mostRecentUpdateDate: Date,
         languageVersions: [BusinessCardLocalization],
         tagIDs: [BusinessCardTagID] = [],
         notes: String = ""
    ) {
        self.id = id
        self.exchangeID = exchangeID
        self.originalID = originalID
        self.ownerID = ownerID
        self.receivingDate = receivingDate
        self.mostRecentUpdateDate = mostRecentUpdateDate
        self.localizations = languageVersions
        self.tagIDs = tagIDs
        self.notes = notes
    }
}

extension ReceivedBusinessCard: Equatable {
    static func == (lhs: ReceivedBusinessCard, rhs: ReceivedBusinessCard) -> Bool {
        lhs.id == rhs.id
    }
}

extension ReceivedBusinessCard: Firestoreable {

}

// MARK: - Coding Keys

extension ReceivedBusinessCard: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case exchangeID
        case originalID
        case ownerID
        case receivingDate
        case mostRecentUpdateDate
        case localizations
        case tagIDs
        case notes
    }
}
