//
//  ReceivedCardDetailsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/09/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase

final class ReceivedCardDetailsVM: CardDetailsVM {

    override var cardLocalization: BusinessCardLocalization? {
        card?.displayedLocalization
    }

    private var card: EditReceivedBusinessCardMC?
    private var updates: (localizations: [BusinessCardLocalization], version: Int)?
    private var tags = [BusinessCardTagMC]()

    private var hasLocalizationUpdates: Bool {
        !(updates?.localizations ?? []).isEmpty
    }
    
    private var tagsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(BusinessCardTag.collectionName)
    }

    private var receivedCardCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
    }

    private var directCardExchangeReference: CollectionReference {
        db.collection(DirectCardExchange.collectionName)
    }

    override func sectionFactory() -> CardDetailsSectionFactory? {
        guard let card = self.card else { return nil }
        let selectedTags = self.tags.filter { card.tagIDs.contains($0.id) }
        return ReceivedCardDetailsSectionFactory(
            card: card.receivedBusinessCardMC(),
            tags: selectedTags,
            isUpdateAvailable: self.hasLocalizationUpdates,
            imageProvider: Self.iconImage
        )
    }

    override func saveLocalizationUpdates() {
        guard let card = self.card else { return }
        guard let updates = self.updates, !updates.localizations.isEmpty else { return }
        card.localizations = updates.localizations
        card.version = updates.version
        card.save(in: receivedCardCollectionReference)
    }

    override func deleteCard() {
        guard let card = self.card else { return }
        card.delete(in: receivedCardCollectionReference)
        delegate?.dismissSelfWithSystemAnimation()
    }

    override func fetchData() {
        receivedCardCollectionReference.document(cardID).addSnapshotListener { [weak self] documentSnapshot, error in
            self?.cardDidChange(documentSnapshot, error)
        }
        tagsCollectionReference.addSnapshotListener { [weak self] querySnapshot, error in
            self?.cardTagsDidChange(querySnapshot, error)
        }
    }

    override func editCardTagsVM() -> EditCardTagsVM? {
        guard let card = card else { return nil }
        let vm = EditCardTagsVM(userID: userID, selectedTagIDs: card.tagIDs)
        vm.selectionDelegate = self
        return vm
    }

    override func editCardNotesVM() -> EditCardNotesVM? {
        guard let card = self.card else { return nil }
        let vm = EditCardNotesVM(notes: card.notes)
        vm.editingDelegate = self
        return vm
    }

    private func cardDidChange(_ document: DocumentSnapshot?, _ error: Error?) {
        guard let doc = document else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching received card changed:", error?.localizedDescription ?? "No error info available.")
            return
        }
        DispatchQueue.global().async {
            guard let card = EditReceivedBusinessCardMC(documentSnapshot: doc) else {
                print(#file, "Error mapping received card:", error?.localizedDescription ?? "No error info available.")
                DispatchQueue.main.async {
                    self.card = nil
                    self.clearSections()
                    self.delegate?.reloadData()
                }
                return
            }

            if let exchangeID = card.exchangeID {
                self.directCardExchangeReference.document(exchangeID).addSnapshotListener { [weak self] documentSnapshot, error in
                    self?.exchangeDidChange(documentSnapshot, error)
                }
            }

            DispatchQueue.main.async {
                self.card = card
                self.makeSections()
            }
        }
    }

    private func exchangeDidChange(_ documentSnapshot: DocumentSnapshot?, _ error: Error?) {

        guard let card = self.card else { return }

        guard let document = documentSnapshot else {
            // TODO: HANDLE ERROR
            print(#file, "Error fetching exchange changed:", error?.localizedDescription ?? "No error info available.")
            return
        }

        guard let exchange = DirectCardExchangeMC(exchangeDocument: document) else {
            print(#file, "Error mapping exchange:", document.documentID)
            return
        }

        if exchange.ownerID == userID && exchange.guestCardVersion > card.version, let localizations = exchange.guestCardLocalizations, !localizations.isEmpty {
            self.updates = (localizations, exchange.guestCardVersion)
        } else if exchange.ownerCardVersion > card.version, !exchange.ownerCardLocalizations.isEmpty {
            self.updates = (exchange.ownerCardLocalizations, exchange.ownerCardVersion)
        } else {
            self.updates = nil
        }
        self.makeSections()
    }

    private func cardTagsDidChange(_ querySnapshot: QuerySnapshot?, _ error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }

        DispatchQueue.global().async {
            var newTags: [BusinessCardTagMC] = querySnap.documents.compactMap {
                guard let tag = BusinessCardTag(queryDocumentSnapshot: $0) else {
                    print(#file, "Error mapping tag:", $0.documentID)
                    return nil
                }
                return BusinessCardTagMC(tag: tag)
            }
            newTags.sort(by: BusinessCardTagMC.sortByPriority)
            DispatchQueue.main.async {
                self.tags = newTags
                self.makeSections()
            }
        }
    }
}

// MARK: - EditCardTagsVMSelectionDelegate

extension ReceivedCardDetailsVM: EditCardTagsVMSelectionDelegate {
    func didChangeSelectedTags(to tags: [BusinessCardTagMC]) {
        guard let card = self.card else { return }
        card.tagIDs = tags.map(\.id)
        card.save(in: receivedCardCollectionReference, fields: [.tagIDs]) { [weak self] result in
            switch result {
            case .success: return
            case .failure(let error):
                print(error.localizedDescription)
                let errorMessage = AppError.localizedUnknownErrorDescription
                self?.delegate?.presentErrorAlert(message: errorMessage)
            }
        }
        makeSections()
    }
}

// MARK: - EditCardNotesVMEditingDelegate

extension ReceivedCardDetailsVM: EditCardNotesVMEditingDelegate {
    func didEditNotes(to editedNotes: String) {
        guard let card = self.card else { return }
        card.notes = editedNotes
        card.save(in: receivedCardCollectionReference, fields: [.notes]) { [weak self] result in
            switch result {
            case .success: return
            case .failure(let error):
                print(error.localizedDescription)
                let errorMessage = AppError.localizedUnknownErrorDescription
                self?.delegate?.presentErrorAlert(message: errorMessage)
            }
        }
        makeSections()
    }
}
