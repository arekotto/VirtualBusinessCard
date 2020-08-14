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

    var defaultLocalization: BusinessCardLocalization {
        guard let defaultData = card.localizations.first(where: { $0.isDefault }) else {
            fatalError("No Default version found for card: \(id)")
        }
        return defaultData
    }

    var mostRecentPush: Date { card.mostRecentPush }

    var mostRecentUpdate: Date { card.mostRecentUpdate }

    var localizations: [BusinessCardLocalization] { card.localizations }

    var cornerRadiusHeightMultiplier: Float { defaultLocalization.cornerRadiusHeightMultiplier }
        
    var frontImage: BusinessCardLocalization.Image { defaultLocalization.frontImage }
    
    var backImage: BusinessCardLocalization.Image { defaultLocalization.backImage }

    var texture: BusinessCardLocalization.Texture { defaultLocalization.texture }

    var position: BusinessCardLocalization.Position { defaultLocalization.position }

    var name: BusinessCardLocalization.Name { defaultLocalization.name }
    
    var contact: BusinessCardLocalization.Contact { defaultLocalization.contact }
    
    var address: BusinessCardLocalization.Address { defaultLocalization.address }
    
    init(businessCard: PersonalBusinessCard) {
        card = businessCard
    }

    func localization(withID id: UUID) -> BusinessCardLocalization? {
        card.localizations.first { $0.id == id }
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

    func editPersonalBusinessCardLocalizationMC(userID: UserID, editedLocalizationID: UUID) -> EditPersonalBusinessCardLocalizationMC {
        EditPersonalBusinessCardLocalizationMC(userID: userID, editedLocalizationID: editedLocalizationID, card: card)
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
