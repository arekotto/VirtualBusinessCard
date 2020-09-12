//
//  EditTagVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase

protocol NewTagVMDelegate: class {
    func applyNewTagColor(_ color: UIColor)
    func presentDeleteAlert()
    func presentErrorAlert(message: String)
    func presentErrorAlert(title: String?, message: String)
    func presentLoadingAlert(title: String)
    func dismissSelf()
}

final class EditTagVM: PartialUserViewModel {
    
    weak var delegate: NewTagVMDelegate?
    
    let title: String
    let allowsDelete: Bool

    private let tag: EditBusinessCardTagMC

    private let selectableTagColors = BusinessCardTag.TagColor.allCases
    
    private var hasMadeChanges = SingleTimeToggleBool(ofInitialValue: false)
    
    init(userID: UserID, editBusinessCardTagMC: EditBusinessCardTagMC) {
        title = NSLocalizedString("Edit Tag", comment: "")
        tag = editBusinessCardTagMC
        allowsDelete = true
        super.init(userID: userID)
    }
    
    init(userID: UserID, estimatedLowestPriorityIndex: Int) {
        title = NSLocalizedString("New Tag", comment: "")
        tag = EditBusinessCardTagMC(estimatedLowestPriorityIndex: estimatedLowestPriorityIndex, color: selectableTagColors.first!)
        allowsDelete = false
        super.init(userID: userID)
    }
}

// MARK: - ViewController API

extension EditTagVM {
    
    var selectedItem: IndexPath? {
        guard let idx = selectableTagColors.firstIndex(of: tag.tagColor) else { return nil }
        return IndexPath(item: idx)
    }
    
    var tagName: String {
        get { tag.title }
        set {
            guard tag.title != newValue else { return }
            tag.title = newValue
            hasMadeChanges.toggle()
        }
    }
    
    var selectedColor: UIColor {
        tag.displayColor
    }
    
    var hasUnsavedChanges: Bool {
        hasMadeChanges.value
    }
    
    func numberOfItems() -> Int {
        selectableTagColors.count
    }
    
    func itemForCell(at indexPath: IndexPath) -> UIColor {
        UIColor.initFrom(tagColor: selectableTagColors[indexPath.item])
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        guard indexPath.item < numberOfItems() else { return }
        tag.tagColor = selectableTagColors[indexPath.item]
        delegate?.applyNewTagColor(tag.displayColor)
        hasMadeChanges.toggle()
    }
    
    func didSelectDelete() {
        guard allowsDelete else { return }
        delegate?.presentDeleteAlert()
    }
    
    func didConfirmDelete() {
        delegate?.presentLoadingAlert(title: NSLocalizedString("Deleting tag", comment: ""))
        let tagIDs = ReceivedBusinessCard.CodingKeys.tagIDs.rawValue
        let query = receivedCardsCollectionReference.whereField(tagIDs, arrayContains: tag.id)
        query.getDocuments(source: .server) { snapshot, error in
            guard let snap = snapshot  else {
                print(#file, "error fetching cards", error?.localizedDescription ?? "")
                let msg = NSLocalizedString("Please check your internet connection and try again.", comment: "")
                self.delegate?.presentErrorAlert(message: msg)
                return
            }
            self.deleteTag(taggedCardIDs: snap.documents.map(\.documentID))
        }
    }
    
    func didSelectDone() {
        guard !tag.title.isEmpty else {
            delegate?.presentErrorAlert(message: NSLocalizedString("Give the tag a name.", comment: ""))
            return
        }
        saveTag()
    }

    private func deleteTag(taggedCardIDs: [BusinessCardID]) {
        let receivedCardsReferences = taggedCardIDs.map { receivedCardsCollectionReference.document($0) }
        let tagReference = tagsCollectionReference.document(tag.id)
            Self.sharedDatabase.runTransaction { [weak self] transaction, errorPointer in
            guard let self = self else { return nil }
            let cards: [EditReceivedBusinessCardMC]
            do {
                cards = try receivedCardsReferences.map {
                    let exchangeDocumentSnap = try transaction.getDocument($0)
                    return try EditReceivedBusinessCardMC(unwrappedWithExchangeDocument: exchangeDocumentSnap)
                }
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            cards.forEach { $0.tagIDs.removeAll(where: {$0 == self.tag.id}) }

            cards.enumerated().forEach { idx, exchange in
                transaction.updateData(exchange.asDocument(), forDocument: receivedCardsReferences[idx])
            }
            transaction.deleteDocument(tagReference)
            return nil
        } completion: { [weak self] _, error in
            if let err = error {
                print(#file, err.localizedDescription)
                let message = NSLocalizedString("We could not push your changes. Please check your network connection and try again.", comment: "")
                self?.delegate?.presentErrorAlert(message: message)
            } else {
                self?.delegate?.dismissSelf()
            }
        }
    }
    
    private func saveTag() {
        tag.save(in: tagsCollectionReference)
        delegate?.dismissSelf()
    }
}

// MARK: - Firebase

extension EditTagVM {
    private var tagsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(BusinessCardTag.collectionName)
    }

    private var receivedCardsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(ReceivedBusinessCard.collectionName)
    }
}
