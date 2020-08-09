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

    private(set) var businessCard: ReceivedBusinessCard
    let displayedCardData: BusinessCardData

    var id: String { businessCard.id }

    var originalID: BusinessCardID { businessCard.originalID }

    var ownerID: UserID { businessCard.ownerID }

    var receivingDate: Date { businessCard.receivingDate }

    var notes: String {
        get { businessCard.notes }
        set { businessCard.notes = newValue }
    }

    var tagIDs: [BusinessCardTagID] {
        get { businessCard.tagIDs }
        set { businessCard.tagIDs = newValue }
    }

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

    func receivedBusinessCardMC() -> ReceivedBusinessCardMC {
        ReceivedBusinessCardMC(card: businessCard)
    }

    init(card: ReceivedBusinessCard) {
        self.businessCard = card
        // TODO: change to detect lang version
        guard let displayedCardData = card.languageVersions.first(where: { $0.isDefault == true }) else {
            fatalError("The card \(card.id) does not contain a default language version")
        }
        self.displayedCardData = displayedCardData
    }
}

extension EditReceivedBusinessCardMC {

    convenience init(originalID: BusinessCardID, ownerID: UserID, languageVersions: [BusinessCardData]) {
        let newCard = ReceivedBusinessCard(id: Self.unsavedObjectID, originalID: originalID, ownerID: ownerID, receivingDate: Date(), languageVersions: languageVersions)
        self.init(card: newCard)
    }

    convenience init?(documentSnapshot: DocumentSnapshot) {
        guard let businessCard = ReceivedBusinessCard(documentSnapshot: documentSnapshot) else { return nil }
        self.init(card: businessCard)
    }

    func save(in collectionReference: CollectionReference, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let docRef: DocumentReference
        if businessCard.id == Self.unsavedObjectID {
            docRef = collectionReference.document()
            businessCard.id = docRef.documentID
        } else {
            docRef = collectionReference.document(businessCard.id)
        }

        docRef.setData(businessCard.asDocument()) { error in
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
        if businessCard.id == Self.unsavedObjectID {
            docRef = collectionReference.document()
            businessCard.id = docRef.documentID
        } else {
            docRef = collectionReference.document(businessCard.id)
        }

        let businessCardDoc = businessCard.asDocument()

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
}

extension EditReceivedBusinessCardMC: Equatable {
    static func == (lhs: EditReceivedBusinessCardMC, rhs: EditReceivedBusinessCardMC) -> Bool {
        lhs.businessCard == rhs.businessCard
    }
}
