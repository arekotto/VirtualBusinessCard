//
//  ReceivedBusinessCardMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 15/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import Contacts

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
    
    var addressFormatted: String {
        
        let addressData = cardData.address
        
        let address = CNMutablePostalAddress()
        address.street = addressData.street ?? ""
        address.city = addressData.city ?? ""
        address.country = addressData.country ?? ""
        address.postalCode = addressData.postCode ?? ""

        return CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
    }
    
    init(card: ReceivedBusinessCard) {
        self.businessCard = card
    }
}

extension ReceivedBusinessCardMC {
    convenience init?(documentSnapshot: DocumentSnapshot) {
        guard let businessCard = ReceivedBusinessCard(documentSnapshot: documentSnapshot) else { return nil }
        self.init(card: businessCard)
    }
}

extension ReceivedBusinessCardMC: Equatable {
    static func == (lhs: ReceivedBusinessCardMC, rhs: ReceivedBusinessCardMC) -> Bool {
        lhs.businessCard == rhs.businessCard
    }
}
