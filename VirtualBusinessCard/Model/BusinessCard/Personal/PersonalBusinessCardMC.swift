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

    var creationDate: Date { card.creationDate }

    var defaultCardData: BusinessCardData {
        guard let defaultData = card.languageVersions.first(where: { $0.isDefault }) else {
            fatalError("No Default version found for card: \(id)")
        }
        return defaultData
    }

    var languageVersions: [BusinessCardData] { card.languageVersions }

    var cornerRadiusHeightMultiplier: Float { defaultCardData.cornerRadiusHeightMultiplier }
        
    var frontImage: BusinessCardData.Image { defaultCardData.frontImage }
    
    var backImage: BusinessCardData.Image { defaultCardData.backImage }

    var texture: BusinessCardData.Texture { defaultCardData.texture }

    var position: BusinessCardData.Position { defaultCardData.position }

    var name: BusinessCardData.Name { defaultCardData.name }
    
    var contact: BusinessCardData.Contact { defaultCardData.contact }
    
    var address: BusinessCardData.Address { defaultCardData.address }
    
    init(businessCard: PersonalBusinessCard) {
        card = businessCard
    }

    func localization(withID id: UUID) -> BusinessCardData? {
        card.languageVersions.first { $0.id == id }
    }
}

extension PersonalBusinessCardMC {
    convenience init?(documentSnapshot: DocumentSnapshot) {
        guard let businessCard = PersonalBusinessCard(documentSnapshot: documentSnapshot) else { return nil }
        self.init(businessCard: businessCard)
    }

    func editPersonalBusinessCardMC(userID: UserID) -> EditPersonalBusinessCardMC {
        EditPersonalBusinessCardMC(userID: userID, existingCard: card)
    }

    func editPersonalBusinessCardLocalizationMC(userID: UserID, editedCardDataID: UUID) -> EditPersonalBusinessCardLocalizationMC {
        EditPersonalBusinessCardLocalizationMC(userID: userID, editedCardDataID: editedCardDataID, card: card)
    }

    func editPersonalBusinessCardLocalizationMC(userID: UserID, newLocalizationLanguageCode: String) -> EditPersonalBusinessCardLocalizationMC {
        EditPersonalBusinessCardLocalizationMC(userID: userID, card: card, newLocalizationLanguageCode: newLocalizationLanguageCode)
    }
}

extension PersonalBusinessCardMC: Equatable {
    static func == (lhs: PersonalBusinessCardMC, rhs: PersonalBusinessCardMC) -> Bool {
        lhs.card == rhs.card
    }
}
