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
        
    var frontImage: BusinessCardData.Image { businessCard.cardData.frontImage }
    
    var backImage: BusinessCardData.Image { businessCard.cardData.backImage }

    var texture: BusinessCardData.Texture { businessCard.cardData.texture }

    var position: BusinessCardData.Position { businessCard.cardData.position }

    var name: BusinessCardData.Name { businessCard.cardData.name }
    
    var contact: BusinessCardData.Contact { businessCard.cardData.contact }
    
    var address: BusinessCardData.Address { businessCard.cardData.address }
    
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
