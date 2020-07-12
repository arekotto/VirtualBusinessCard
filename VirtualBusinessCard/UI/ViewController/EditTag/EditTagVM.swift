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
    func presentSaveErrorAlert(title: String)
    func dismissSelf()
}

final class EditTagVM: AppViewModel {
    
    weak var delegate: NewTagVMDelegate?
    
    let title: String
    let allowsDelete: Bool

    private let tag: EditBusinessCardTagMC

    private let selectableTagColors = BusinessCardTag.TagColor.allCases
    
    private var hasMadeChanges = SingleTimeToggleBool()
    
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
        case .wifi, .cellular, .some(.none), .none: return true
        case .unavailable: return false
        }
    }
}

// MARK: - ViewController API

extension EditTagVM {
    
    var doneEditingButtonTitle: String {
        NSLocalizedString("Done", comment: "")
    }
    
    var cancelEditingButtonTitle: String {
        NSLocalizedString("Cancel", comment: "")
    }
    
    var selectedItem: IndexPath? {
        guard let idx = selectableTagColors.firstIndex(of: tag.tagColor) else { return nil }
        return IndexPath(item: idx)
    }
    
    var tagName: String {
        get { tag.title }
        set {
            guard tag.title != newValue else { return }
            tag.title = newValue
            hasMadeChanges.setToTrue()
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
        hasMadeChanges.setToTrue()
    }
    
    func didAttemptDismiss() {
        delegate?.presentDismissAlert()
    }
    
    func didSelectDelete() {
        guard allowsDelete else { return }
        delegate?.presentDeleteAlert()
    }
    
    func didConfirmDelete() {
        tag.delete(in: tagsCollectionReference)
        delegate?.dismissSelf()
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
            delegate?.presentSaveErrorAlert(title: NSLocalizedString("Give the tag a name.", comment: ""))
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
            case .success(): return
            case .failure(let error): encounteredError = error
            }
        }
        
        // give firebase some time to return an error if something is very wrong
        // otherwise data will be stored in cache if offline
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let error = encounteredError {
                print(error.localizedDescription)
                let errorTitle = AppError.localizedUnknownErrorDescription
                self.delegate?.presentSaveErrorAlert(title: errorTitle)
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
}
