//
//  EditPersonalBusinessCardLocalizationMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

class EditPersonalBusinessCardLocalizationMC {

    private static let unsavedObjectID = ""
    private static let unsavedImageID = ""
    private static let unsavedImageURL = URL(string: "0")!

    let storage = Storage.storage().reference()
    let userID: UserID
    let editedLocalizationID: UUID

    private var card: PersonalBusinessCard

    var cardID: String { card.id }

    var editedLocalization: BusinessCardLocalization {
        get {
            guard let editedLocalization = card.localizations.first(where: { $0.id == editedLocalizationID }) else {
                fatalError("The card \(cardID) does not contain a language version with id \(editedLocalizationID)")
            }
            return editedLocalization
        }
        set {
            guard let editedLocalizationIndex = card.localizations.firstIndex(where: { $0.id == editedLocalizationID }) else {
                fatalError("The card \(cardID) does not contain a language version with id \(editedLocalizationID)")
            }
            card.localizations[editedLocalizationIndex] = newValue
        }
    }

    var cornerRadiusHeightMultiplier: Float {
        get { editedLocalization.cornerRadiusHeightMultiplier }
        set { editedLocalization.cornerRadiusHeightMultiplier = newValue }
    }

    var frontImage: BusinessCardLocalization.Image {
        get { editedLocalization.frontImage }
        set { editedLocalization.frontImage = newValue }
    }

    var backImage: BusinessCardLocalization.Image {
        get { editedLocalization.backImage }
        set { editedLocalization.backImage = newValue }
    }
    var texture: BusinessCardLocalization.Texture {
        get { editedLocalization.texture }
        set { editedLocalization.texture = newValue }
    }

    var position: BusinessCardLocalization.Position {
        get { editedLocalization.position }
        set { editedLocalization.position = newValue }
    }

    var name: BusinessCardLocalization.Name {
        get { editedLocalization.name }
        set { editedLocalization.name = newValue }
    }

    var contact: BusinessCardLocalization.Contact {
        get { editedLocalization.contact }
        set { editedLocalization.contact = newValue }
    }

    var address: BusinessCardLocalization.Address {
        get { editedLocalization.address }
        set { editedLocalization.address = newValue }
    }

    var localizations: [BusinessCardLocalization] {
        get { card.localizations }
        set { card.localizations = newValue }
    }

    init(userID: UserID, editedLocalizationID: UUID, card: PersonalBusinessCard) {
        self.userID = userID
        self.editedLocalizationID = editedLocalizationID
        self.card = card
    }

    func asDocument() -> [String: Any] {
        card.asDocument()
    }
}

extension EditPersonalBusinessCardLocalizationMC {

    static func makeLanguageVersion(isDefault: Bool, languageCode: String?) -> BusinessCardLocalization {
        BusinessCardLocalization(
            id: UUID(),
            frontImage: BusinessCardLocalization.Image(id: Self.unsavedImageID, url: Self.unsavedImageURL),
            backImage: BusinessCardLocalization.Image(id: Self.unsavedImageID, url: Self.unsavedImageURL),
            texture: BusinessCardLocalization.Texture(image: BusinessCardLocalization.Image(id: Self.unsavedImageID, url: Self.unsavedImageURL), specular: 0.5, normal: 0.5),
            position: BusinessCardLocalization.Position(),
            name: BusinessCardLocalization.Name(),
            contact: BusinessCardLocalization.Contact(),
            address: BusinessCardLocalization.Address(),
            hapticFeedbackSharpness: 0.5,
            cornerRadiusHeightMultiplier: 0,
            isDefault: isDefault,
            languageCode: languageCode
        )
    }

    func personalBusinessCardMC() -> PersonalBusinessCardMC {
        PersonalBusinessCardMC(businessCard: card)
    }

    convenience init(userID: UserID, card: PersonalBusinessCard, newLocalizationLanguageCode langCode: String) {
        var editedCard = card
        let newLanguageVersion = Self.makeLanguageVersion(isDefault: false, languageCode: langCode)
        editedCard.localizations.append(newLanguageVersion)
        self.init(userID: userID, editedLocalizationID: newLanguageVersion.id, card: editedCard)
    }

    convenience init(userID: UserID) {
        let defaultLanguageVersion = Self.makeLanguageVersion(isDefault: true, languageCode: nil)
        let newCard = PersonalBusinessCard(id: Self.unsavedObjectID, creationDate: Date(), localizations: [defaultLanguageVersion])
        self.init(userID: userID, editedLocalizationID: defaultLanguageVersion.id, card: newCard)
    }
}

extension EditPersonalBusinessCardLocalizationMC: Equatable {
    static func == (lhs: EditPersonalBusinessCardLocalizationMC, rhs: EditPersonalBusinessCardLocalizationMC) -> Bool {
        lhs.card == rhs.card
    }
}

extension EditPersonalBusinessCardLocalizationMC {
    var imageStoragePath: String {
        "\(userID)/\(editedLocalizationID)"
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
