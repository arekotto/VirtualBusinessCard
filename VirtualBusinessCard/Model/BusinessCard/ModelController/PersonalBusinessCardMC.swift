//
//  PersonalBusinessCardMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 06/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

class PersonalBusinessCardMC {

    let storage = Storage.storage().reference()
    
    let businessCard: PersonalBusinessCard
    
    var id: String { businessCard.id }
        
    var frontImage: BusinessCardData.Image { businessCard.cardData.frontImage }
    
    var backImage: BusinessCardData.Image { businessCard.cardData.backImage }

    var texture: BusinessCardData.Texture { businessCard.cardData.texture }

    var position: BusinessCardData.Position { businessCard.cardData.position }

    var name: BusinessCardData.Name { businessCard.cardData.name }
    
    var contact: BusinessCardData.Contact { businessCard.cardData.contact }
    
    var address: BusinessCardData.Address { businessCard.cardData.address }
    
    init(businessCard: PersonalBusinessCard) {
        self.businessCard = businessCard
    }
}

extension PersonalBusinessCardMC {
    convenience init?(userPublicDocument: DocumentSnapshot) {
        guard let businessCard = PersonalBusinessCard(documentSnapshot: userPublicDocument) else { return nil }
        self.init(businessCard: businessCard)
    }
}

extension PersonalBusinessCardMC: Equatable {
    static func == (lhs: PersonalBusinessCardMC, rhs: PersonalBusinessCardMC) -> Bool {
        lhs.businessCard == rhs.businessCard
    }
}
