//
//  ViewBusinessCardMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 06/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

class ViewBusinessCardMC: BusinessCardMC {

    let storage = Storage.storage().reference()
    
    let businessCard: BusinessCard
    
    var id: String { businessCard.id }
    
    var originalID: String? { businessCard.originalID }
    
    var frontImage: BusinessCard.Image? { businessCard.frontImage }
    
    var backImage: BusinessCard.Image? { businessCard.backImage }

    var texture: BusinessCard.Texture? { businessCard.texture }

    var position: BusinessCard.Position { businessCard.position }

    var name: BusinessCard.Name { businessCard.name }
    
    var contact: BusinessCard.Contact { businessCard.contact }
    
    var address: BusinessCard.Address { businessCard.address }
    
    init(businessCard: BusinessCard) {
        self.businessCard = businessCard
    }
}

extension ViewBusinessCardMC {
    convenience init?(userPublicDocument: DocumentSnapshot) {
        guard let businessCard = BusinessCard(documentSnapshot: userPublicDocument) else { return nil }
        self.init(businessCard: businessCard)
    }
}

extension ViewBusinessCardMC: Equatable {
    static func == (lhs: ViewBusinessCardMC, rhs: ViewBusinessCardMC) -> Bool {
        lhs.businessCard == rhs.businessCard
    }
}
