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
    var originalID: BusinessCardID
    var ownerID: UserID
    var receivingDate: Date
    var version: Int
    var localizations: [BusinessCardLocalization]
    var tagIDs: [BusinessCardTagID]
    var notes: String
    var exchangeID: DirectCardExchangeID?
    
    init(id: BusinessCardID,
         exchangeID: DirectCardExchangeID?,
         originalID: BusinessCardID,
         ownerID: UserID,
         receivingDate: Date,
         version: Int,
         localizations: [BusinessCardLocalization],
         tagIDs: [BusinessCardTagID] = [],
         notes: String = ""
    ) {
        self.id = id
        self.exchangeID = exchangeID
        self.originalID = originalID
        self.ownerID = ownerID
        self.receivingDate = receivingDate
        self.version = version
        self.localizations = localizations
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
        case version
        case localizations
        case tagIDs
        case notes
    }
}
