//
//  EditReceivedBusinessCardMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 20/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import Contacts

final class EditReceivedBusinessCardMC {

    static private let unsavedObjectID = ""

    private(set) var card: ReceivedBusinessCard
    let displayedLocalization: BusinessCardLocalization

    var id: String { card.id }

    var originalID: BusinessCardID { card.originalID }

    var ownerID: UserID { card.ownerID }

    var receivingDate: Date { card.receivingDate }

    var exchangeID: DirectCardExchangeID { card.exchangeID }

    var localizations: [BusinessCardLocalization] {
        get { card.localizations }
        set { card.localizations = newValue }
    }

    var mostRecentUpdateDate: Date {
        get { card.mostRecentUpdateDate }
        set { card.mostRecentUpdateDate = newValue }
    }

    var notes: String {
        get { card.notes }
        set { card.notes = newValue }
    }

    var tagIDs: [BusinessCardTagID] {
        get { card.tagIDs }
        set { card.tagIDs = newValue }
    }

    var ownerDisplayName: String {
        if let firstName = displayedLocalization.name.first, let lastName = displayedLocalization.name.last {
            return "\(firstName) \(lastName)"
        }
        return displayedLocalization.name.first ?? displayedLocalization.name.last ?? ""
    }

    var addressCondensed: String {
        let addressData = displayedLocalization.address
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

        let addressData = displayedLocalization.address

        let address = CNMutablePostalAddress()
        address.street = addressData.street ?? ""
        address.city = addressData.city ?? ""
        address.country = addressData.country ?? ""
        address.postalCode = addressData.postCode ?? ""

        return CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
    }

    func receivedBusinessCardMC() -> ReceivedBusinessCardMC {
        ReceivedBusinessCardMC(card: card)
    }

    init(card: ReceivedBusinessCard) {
        let currentLocale = Locale.current
        let matchingLocalization = card.localizations.first(where: { $0.languageCode == currentLocale.languageCode })
        let localization = matchingLocalization ?? card.localizations.first(where: { $0.isDefault == true })
        guard let displayedLocalization = localization else {
            fatalError("The card \(card.id) does not contain a default language version")
        }
        self.displayedLocalization = displayedLocalization
        self.card = card
    }

    func asDocument() -> [String: Any] {
        card.asDocument()
    }
}

extension EditReceivedBusinessCardMC {

    convenience init(originalID: BusinessCardID, exchangeID: DirectCardExchangeID, ownerID: UserID, languageVersions: [BusinessCardLocalization]) {
        let newCard = ReceivedBusinessCard(
            id: Self.unsavedObjectID,
            exchangeID: exchangeID,
            originalID: originalID,
            ownerID: ownerID,
            receivingDate: Date(),
            mostRecentUpdateDate: Date(),
            languageVersions: languageVersions
        )
        self.init(card: newCard)
    }

    convenience init?(documentSnapshot: DocumentSnapshot) {
        guard let businessCard = ReceivedBusinessCard(documentSnapshot: documentSnapshot) else { return nil }
        self.init(card: businessCard)
    }

    convenience init(unwrappedWithExchangeDocument cardDocument: DocumentSnapshot) throws {
        self.init(card: try ReceivedBusinessCard(unwrappedWithDocumentSnapshot: cardDocument))
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

    func save(in collectionReference: CollectionReference, fields: [ReceivedBusinessCard.CodingKeys], completion: ((Result<Void, Error>) -> Void)? = nil) {
        let docRef: DocumentReference
        if card.id == Self.unsavedObjectID {
            docRef = collectionReference.document()
            card.id = docRef.documentID
        } else {
            docRef = collectionReference.document(card.id)
        }

        let businessCardDoc = card.asDocument()

        let updates = fields.reduce(into: [String: Any]()) { updates, key in
            updates[key.rawValue] = businessCardDoc[key.rawValue]
        }

        docRef.updateData(updates) { error in
            if let err = error {
                print(err.localizedDescription)
                completion?(.failure(err))
            } else {
                completion?(.success(()))
            }
        }
    }

    func delete(in collectionReference: CollectionReference, completion: ((Result<Void, Error>) -> Void)? = nil) {
        collectionReference.document(card.id).delete { error in
            if let err = error {
                print(err.localizedDescription)
                completion?(.failure(err))
            } else {
                completion?(.success(()))
            }
        }
    }
}

extension EditReceivedBusinessCardMC: Equatable {
    static func == (lhs: EditReceivedBusinessCardMC, rhs: EditReceivedBusinessCardMC) -> Bool {
        lhs.card == rhs.card
    }
}
