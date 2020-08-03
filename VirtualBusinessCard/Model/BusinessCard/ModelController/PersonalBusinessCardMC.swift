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
    
    private let card: PersonalBusinessCard
    
    var id: String { card.id }

    var cardData: BusinessCardData { card.cardData }

    var cornerRadiusHeightMultiplier: Float { card.cardData.cornerRadiusHeightMultiplier }
        
    var frontImage: BusinessCardData.Image { card.cardData.frontImage }
    
    var backImage: BusinessCardData.Image { card.cardData.backImage }

    var texture: BusinessCardData.Texture { card.cardData.texture }

    var position: BusinessCardData.Position { card.cardData.position }

    var name: BusinessCardData.Name { card.cardData.name }
    
    var contact: BusinessCardData.Contact { card.cardData.contact }
    
    var address: BusinessCardData.Address { card.cardData.address }
    
    init(businessCard: PersonalBusinessCard) {
        card = businessCard
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
        lhs.card == rhs.card
    }
}
