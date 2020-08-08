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

    let userID: UserID

    var id: String { card.id }

    var cardData: BusinessCardData {
        get { card.cardData }
        set { card.cardData = newValue }
    }

    var cornerRadiusHeightMultiplier: Float {
        get { card.cardData.cornerRadiusHeightMultiplier }
        set { card.cardData.cornerRadiusHeightMultiplier = newValue }
    }

    var frontImage: BusinessCardData.Image  {
        get { card.cardData.frontImage }
        set { card.cardData.frontImage = newValue }
    }

    var backImage: BusinessCardData.Image {
        get { card.cardData.backImage }
        set { card.cardData.backImage = newValue }
    }
    var texture: BusinessCardData.Texture {
        get { card.cardData.texture }
        set { card.cardData.texture = newValue }
    }

    var position: BusinessCardData.Position {
        get { card.cardData.position }
        set { card.cardData.position = newValue }
    }

    var name: BusinessCardData.Name {
        get { card.cardData.name }
        set { card.cardData.name = newValue }
    }

    var contact: BusinessCardData.Contact {
        get { card.cardData.contact }
        set { card.cardData.contact = newValue }
    }

    var address: BusinessCardData.Address {
        get { card.cardData.address }
        set { card.cardData.address = newValue }
    }

    init(userID: UserID, businessCard: PersonalBusinessCard) {
        self.userID = userID
        card = businessCard
    }
}

extension EditPersonalBusinessCardMC {

    func personalBusinessCardMC() -> PersonalBusinessCardMC {
        PersonalBusinessCardMC(businessCard: card)
    }

    convenience init(userID: UserID) {
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
        self.init(userID: userID, businessCard: PersonalBusinessCard(id: Self.unsavedImageID, creationDate: Date(), cardData: data))
    }
}

extension EditPersonalBusinessCardMC: Equatable {
    static func == (lhs: EditPersonalBusinessCardMC, rhs: EditPersonalBusinessCardMC) -> Bool {
        lhs.card == rhs.card
    }
}

extension EditPersonalBusinessCardMC {
    var imageStoragePath: String {
        "\(userID)/\(id)"
    }

    var frontImageStoragePath: String? {
        let frontImageID = frontImage.id
        guard frontImageID != Self.unsavedImageID else { return nil }
        return "\(imageStoragePath)/\(frontImageID)"
    }

    var backImageStoragePath: String? {
        let backImageID = backImage.id
        guard backImageID != Self.unsavedImageID else { return nil }
        return "\(imageStoragePath)/\(backImageID)"
    }

    var textureImageStoragePath: String? {
        let textureImageID = texture.image.id
        guard textureImageID != Self.unsavedImageID else { return nil }
        return "\(imageStoragePath)/\(textureImageID)"
    }

    func save(in collectionReference: CollectionReference, completion: ((Result<Void, Error>) -> Void)? = nil) {

        let docRef: DocumentReference
        if card.id == Self.unsavedObjectID {
            docRef = collectionReference.document()
            card.id = docRef.documentID
        } else {
            docRef = collectionReference.document(card.id)
        }

        docRef.setData(card.asDocument()) { error in
            if let err = error {
                print(err.localizedDescription)
                completion?(.failure(err))
            } else {
                completion?(.success(()))
            }
        }
    }
}
