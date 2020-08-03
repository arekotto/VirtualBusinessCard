//
//  EditPersonalBusinessCardMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

class EditPersonalBusinessCardMC {

    private static let unsavedObjectID = ""
    private static let unsavedImageID = ""
    private static let unsavedImageURL = URL(string: "0")!

    let storage = Storage.storage().reference()

    private var card: PersonalBusinessCard

    var id: String { card.id }

    var cardData: BusinessCardData {
        get { card.cardData }
        set { card.cardData = newValue }
    }

    var cornerRadiusHeightMultiplier: Float {
        get { card.cardData.cornerRadiusHeightMultiplier }
        set { card.cardData.cornerRadiusHeightMultiplier = newValue }
    }

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

extension EditPersonalBusinessCardMC {

    func personalBusinessCardMC() -> PersonalBusinessCardMC {
        PersonalBusinessCardMC(businessCard: card)
    }

    convenience init() {
        let data = BusinessCardData(
            frontImage: BusinessCardData.Image(id: Self.unsavedImageID, url: Self.unsavedImageURL),
            backImage: BusinessCardData.Image(id: Self.unsavedImageID, url: Self.unsavedImageURL),
            texture: BusinessCardData.Texture(image: BusinessCardData.Image(id: Self.unsavedImageID, url: Self.unsavedImageURL), specular: 0.5, normal: 0.5),
            position: BusinessCardData.Position(),
            name: BusinessCardData.Name(),
            contact: BusinessCardData.Contact(),
            address: BusinessCardData.Address(),
            hapticFeedbackSharpness: 0.5,
            cornerRadiusHeightMultiplier: 0
        )
        self.init(businessCard: PersonalBusinessCard(id: Self.unsavedImageID, creationDate: Date(), cardData: data))
    }

    convenience init?(userPublicDocument: DocumentSnapshot) {
        guard let businessCard = PersonalBusinessCard(documentSnapshot: userPublicDocument) else { return nil }
        self.init(businessCard: businessCard)
    }
}

extension EditPersonalBusinessCardMC: Equatable {
    static func == (lhs: EditPersonalBusinessCardMC, rhs: EditPersonalBusinessCardMC) -> Bool {
        lhs.card == rhs.card
    }
}
