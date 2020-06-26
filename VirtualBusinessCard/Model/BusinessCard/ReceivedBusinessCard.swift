//
//  ReceivedBusinessCard.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 15/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

struct ReceivedBusinessCard: Codable {
    var id: BusinessCardID
    var originalID: BusinessCardID
    var ownerID: UserID
    var receivingDate: Date
    var cardData: BusinessCardData
    var tagIDs: [BusinessCardTagID]
    
    internal init(id: BusinessCardID, originalID: BusinessCardID, ownerID: UserID, receivingDate: Date, cardData: BusinessCardData, tagIDs: [BusinessCardTagID] = []) {
        self.id = id
        self.originalID = originalID
        self.ownerID = ownerID
        self.receivingDate = receivingDate
        self.cardData = cardData
        self.tagIDs = tagIDs
    }
}

extension ReceivedBusinessCard: Equatable {
    static func == (lhs: ReceivedBusinessCard, rhs: ReceivedBusinessCard) -> Bool {
        lhs.id == rhs.id
    }
}

extension ReceivedBusinessCard: Firestoreable {

}
