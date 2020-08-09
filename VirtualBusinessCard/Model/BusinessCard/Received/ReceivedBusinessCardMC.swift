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
    
    let card: ReceivedBusinessCard
    let displayedCardData: BusinessCardData
    
    var id: String { card.id }
    
    var originalID: BusinessCardID { card.originalID }
    
    var ownerID: UserID { card.ownerID }
    
    var receivingDate: Date { card.receivingDate }

    var notes: String { card.notes }
    
    var tagIDs: [BusinessCardTagID] { card.tagIDs }

    var languageVersions: [BusinessCardData] { card.languageVersions }
    
    var ownerDisplayName: String {
        if let firstName = displayedCardData.name.first, let lastName = displayedCardData.name.last {
            return "\(firstName) \(lastName)"
        }
        return displayedCardData.name.first ?? displayedCardData.name.last ?? ""
    }
    
    var addressCondensed: String {
        let addressData = displayedCardData.address
        var address = ""
        if let street = addressData.street, !street.isEmpty {
            address.append(street + ",")
        }
        if let city = addressData.city, !city.isEmpty {
            address.append(city + ",")
        }
        if let postCode = addressData.postCode, !postCode.isEmpty {
            address.append(postCode + ",")
        }
        if let country = addressData.country, !country.isEmpty {
            address.append(country)
        }
        return address
    }
    
    var addressFormatted: String {
        
        let addressData = displayedCardData.address
        
        let address = CNMutablePostalAddress()
        address.street = addressData.street ?? ""
        address.city = addressData.city ?? ""
        address.country = addressData.country ?? ""
        address.postalCode = addressData.postCode ?? ""

        return CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
    }

    var receivingDataFormatted: String {
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .long
        return df.string(from: receivingDate)
    }

    func editReceivedBusinessCardMC() -> EditReceivedBusinessCardMC {
        EditReceivedBusinessCardMC(card: card)
    }
    
    init(card: ReceivedBusinessCard) {
        self.card = card
        // TODO: change to detect lang version
        guard let displayedCardData = card.languageVersions.first(where: { $0.isDefault == true }) else {
            fatalError("The card \(card.id) does not contain a default language version")
        }
        self.displayedCardData = displayedCardData
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
        lhs.card == rhs.card
    }
}
