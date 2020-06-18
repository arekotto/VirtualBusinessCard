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
    var receivingDate: Date
    var cardData: BusinessCardData
}

extension ReceivedBusinessCard: Equatable {
    static func == (lhs: ReceivedBusinessCard, rhs: ReceivedBusinessCard) -> Bool {
        lhs.id == rhs.id
    }
}

extension ReceivedBusinessCard: Firestoreable {

}
