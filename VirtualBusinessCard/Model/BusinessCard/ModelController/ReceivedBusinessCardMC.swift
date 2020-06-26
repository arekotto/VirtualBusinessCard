//
//  ReceivedBusinessCardMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 15/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

class ReceivedBusinessCardMC {

    let storage = Storage.storage().reference()
    
    let businessCard: ReceivedBusinessCard
    
    var id: String { businessCard.id }
    
    var originalID: BusinessCardID { businessCard.originalID }
    
    var ownerID: UserID { businessCard.ownerID }
    
    var receivingDate: Date { businessCard.receivingDate }
    
    var cardData: BusinessCardData { businessCard.cardData }
    
    var tagIDs: [BusinessCardTagID] { businessCard.tagIDs }
    
    var ownerDisplayName: String {
        if let firstName = businessCard.cardData.name.first, let lastName = businessCard.cardData.name.last {
            return "\(firstName) \(lastName)"
        }
        return businessCard.cardData.name.first ?? businessCard.cardData.name.last ?? ""
    }
    
    init(card: ReceivedBusinessCard) {
        self.businessCard = card
    }
}

extension ReceivedBusinessCardMC {
    convenience init?(userPublicDocument: DocumentSnapshot) {
        guard let businessCard = ReceivedBusinessCard(documentSnapshot: userPublicDocument) else { return nil }
        self.init(card: businessCard)
    }
}

extension ReceivedBusinessCardMC: Equatable {
    static func == (lhs: ReceivedBusinessCardMC, rhs: ReceivedBusinessCardMC) -> Bool {
        lhs.businessCard == rhs.businessCard
    }
}
