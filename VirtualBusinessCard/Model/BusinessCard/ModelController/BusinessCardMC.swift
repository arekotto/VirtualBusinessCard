//
//  BusinessCardMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 05/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

protocol BusinessCardMC: ModelController where Model == BusinessCard {
    var businessCard: BusinessCard { get }
}

extension BusinessCardMC {
    static func imagePath(userID: UserID, businessCardID: BusinessCardID, imageID: BusinessCard.ImageID) -> String {
        "\(userID)/\(businessCardID)/\(imageID)"
    }
    
    func isModelEqual(to card: BusinessCard) -> Bool {
        businessCard.id == card.id
    }
    
    func asDocument() -> [String : Any] {
        businessCard.asDocument()
    }
}
