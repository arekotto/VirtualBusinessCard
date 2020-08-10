//
//  EditTagVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import Firebase
import Reachability

protocol NewTagVMDelegate: class {
    func applyNewTagColor(_ color: UIColor)
    func presentDismissAlert()
    func presentDeleteAlert()
    func presentSaveOfflineAlert()
    func presentErrorAlert(message: String)
    func presentErrorAlert(title: String?, message: String)
    func presentLoadingAlert(viewModel: LoadingPopoverVM)
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
    
    private func isOnline() -> Bool {
        switch (try? Reachability())?.connection {
        case .wifi, .cellular, .some(.none), nil: return true
        case .unavailable: return false
        }
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
    
    var isAllowedDragToDismiss: Bool {
        !hasMadeChanges.value
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
    
    func didAttemptDismiss() {
        delegate?.presentDismissAlert()
    }
    
    func didSelectDelete() {
        guard allowsDelete else { return }
        delegate?.presentDeleteAlert()
    }
    
    func didConfirmDelete() {
        delegate?.presentLoadingAlert(viewModel: LoadingPopoverVM(title: NSLocalizedString("Deleting tag", comment: "")))
        let tagIDs = ReceivedBusinessCard.CodingKeys.tagIDs.rawValue
        let query = receivedCardsCollectionReference.whereField(tagIDs, arrayContains: tag.id)
        query.getDocuments(source: .server) { snap, error in
            if let err = error {
                print(err.localizedDescription)
                let msg = NSLocalizedString("Please check your internet connection and try again.", comment: "")
                self.delegate?.presentErrorAlert(message: msg)
            } else {
                snap?.documents.forEach {
                    let card = EditReceivedBusinessCardMC(documentSnapshot: $0)
                    card?.tagIDs.removeAll { $0 == self.tag.id }
                    card?.save(in: self.receivedCardsCollectionReference, fields: [.tagIDs])
                }
                self.tag.delete(in: self.tagsCollectionReference)
                self.delegate?.dismissSelf()
            }
        }
    }
    
    func didSelectCancel() {
        guard !hasMadeChanges.value else {
            delegate?.presentDismissAlert()
            return
        }
        delegate?.dismissSelf()
    }
    
    func didSelectDone() {
        guard !tag.title.isEmpty else {
            delegate?.presentErrorAlert(message: NSLocalizedString("Give the tag a name.", comment: ""))
            return
        }
        guard isOnline() else {
            delegate?.presentSaveOfflineAlert()
            return
        }
        saveTag()
    }
    
    func didSelectSaveOffline() {
        saveTag()
    }
    
    private func saveTag() {
        var encounteredError: Error?
        tag.save(in: tagsCollectionReference) { result in
            switch result {
            case .success: return
            case .failure(let error):
                print(error.localizedDescription)
                encounteredError = error
            }
        }
        
        // give firebase some time to return an error if something is very wrong
        // otherwise data will be stored in cache if offline
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if encounteredError != nil {
                let errorTitle = AppError.localizedUnknownErrorDescription
                self.delegate?.presentErrorAlert(message: errorTitle)
            } else {
                self.delegate?.dismissSelf()
            }
        }
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
