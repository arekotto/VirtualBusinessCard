//
//  EditPersonalBusinessCardMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 10/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

class EditPersonalBusinessCardMC {

    let storage = Storage.storage().reference()
    let userID: UserID

    private var card: PersonalBusinessCard

    var cardID: String { card.id }

    var localizations: [BusinessCardLocalization] {
        get { card.languageVersions }
        set { card.languageVersions = newValue }
    }

    init(userID: UserID, existingCard: PersonalBusinessCard) {
        self.userID = userID
        self.card = existingCard
    }
}

extension EditPersonalBusinessCardMC {

    func setDefaultLocalization(toID newDefaultLocalizationID: UUID) {
        [Int](0..<localizations.count).forEach { idx in
            localizations[idx].isDefault = localizations[idx].id == newDefaultLocalizationID
        }
    }

    func deleteLocalization(withID localizationID: UUID) {
        guard let deletedLocalizationIndex = localizations.firstIndex(where: { $0.id == localizationID }) else {
            fatalError("Localization with id \(localizationID) doesn't exist!")
        }

        guard localizations.count >= 2 else {
            fatalError("Deleting last localization not supported. Use delete() method instead.")
        }

        let deletedLocalization = localizations[deletedLocalizationIndex]
        localizations.remove(at: deletedLocalizationIndex)
        if deletedLocalization.isDefault {
            localizations[0].isDefault = true
        }
    }

    func personalBusinessCardMC() -> PersonalBusinessCardMC {
        PersonalBusinessCardMC(businessCard: card)
    }
}

extension EditPersonalBusinessCardMC: Equatable {
    static func == (lhs: EditPersonalBusinessCardMC, rhs: EditPersonalBusinessCardMC) -> Bool {
        lhs.card == rhs.card
    }
}

extension EditPersonalBusinessCardMC {

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

    func save(in collectionReference: CollectionReference, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let docRef = collectionReference.document(card.id)
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
