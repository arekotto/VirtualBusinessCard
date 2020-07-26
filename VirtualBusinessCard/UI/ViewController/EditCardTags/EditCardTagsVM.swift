//
//  EditCardTagsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation
import Firebase
import UIKit

protocol EditCardTagsVMDelegate: class {
    func refreshData()
    func refreshRowAnimated(at indexPath: IndexPath)
    func presentDismissAlert()
    func dismiss()
}

protocol EditCardTagsVMSelectionDelegate: class {
    func didChangeSelectedTags(to tags: [BusinessCardTagMC])
}

final class EditCardTagsVM: PartialUserViewModel {

    weak var delegate: EditCardTagsVMDelegate?
    weak var selectionDelegate: EditCardTagsVMSelectionDelegate?

    private var tags = [BusinessCardTagMC]()

    private let initiallySelectedTagIDs: [BusinessCardTagID]
    private var selectedTagIDs: [BusinessCardTagID]

    private var hasMadeChanges: Bool {
        Set(selectedTagIDs) != Set(initiallySelectedTagIDs)
    }

    init(userID: UserID, selectedTagIDs: [BusinessCardTagID]) {
        self.initiallySelectedTagIDs = selectedTagIDs
        self.selectedTagIDs = selectedTagIDs
        super.init(userID: userID)
    }

    private func tagForRow(at indexPath: IndexPath) -> BusinessCardTagMC {
        tags[indexPath.row]
    }
}

extension EditCardTagsVM {
    var title: String {
        NSLocalizedString("Add Tags", comment: "")
    }

    var doneEditingButtonTitle: String {
        NSLocalizedString("Done", comment: "")
    }

    var cancelEditingButtonTitle: String {
        NSLocalizedString("Cancel", comment: "")
    }

    var isAllowedDragToDismiss: Bool {
        !hasMadeChanges
    }

    func numberOfItems() -> Int {
        tags.count
    }

    func itemForRow(at indexPath: IndexPath) -> TagTableCell.DataModel {
        let tag = tagForRow(at: indexPath)
        return TagTableCell.DataModel(
            tagName: tag.title,
            tagColor: tag.displayColor,
            accessoryImage: accessoryImage(for: tag.id)
        )
    }

    func didSelectItem(at indexPath: IndexPath) {
        let tagID = tagForRow(at: indexPath).id
        if let selectedTagIndex = selectedTagIDs.firstIndex(of: tagID) {
            selectedTagIDs.remove(at: selectedTagIndex)
        } else {
            selectedTagIDs.append(tagID)
        }
        delegate?.refreshRowAnimated(at: indexPath)
    }

    func didApproveSelection() {
        if hasMadeChanges {
            let selectedTags = selectedTagIDs.compactMap { tagID in tags.first(where: { tag in tag.id == tagID }) }
            selectionDelegate?.didChangeSelectedTags(to: selectedTags.sorted(by: BusinessCardTagMC.sortByPriority))
        }
        delegate?.dismiss()
    }

    func didAttemptDismiss() {
        delegate?.presentDismissAlert()
    }

    func didDiscardSelection() {
        delegate?.dismiss()
    }
}

// MARK: - AccessoryImage

private extension EditCardTagsVM {

    static let accessoryImageConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)

    static let selectedAccessoryImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: accessoryImageConfiguration)!

    static let deselectedAccessoryImage = UIImage(systemName: "circle", withConfiguration: accessoryImageConfiguration)!

    func accessoryImage(for tagID: BusinessCardTagID) -> UIImage {
        selectedTagIDs.contains(tagID) ? Self.selectedAccessoryImage : Self.deselectedAccessoryImage
    }
}

// MARK: - Firebase fetch

extension EditCardTagsVM {
    private var tagsCollectionReference: CollectionReference {
        userPublicDocumentReference.collection(BusinessCardTag.collectionName)
    }

    func fetchData() {
        tagsCollectionReference.addSnapshotListener { [weak self] querySnapshot, error in
            self?.cardTagsDidChange(querySnapshot, error)
        }
    }

    private func cardTagsDidChange(_ querySnapshot: QuerySnapshot?, _ error: Error?) {
        guard let querySnap = querySnapshot else {
            print(#file, error?.localizedDescription ?? "")
            return
        }

        DispatchQueue.global().async {
            var newTags: [BusinessCardTagMC] = querySnap.documents.compactMap {
                guard let tag = BusinessCardTag(queryDocumentSnapshot: $0) else {
                    print(#file, "Error mapping business card:", $0.documentID)
                    return nil
                }
                return BusinessCardTagMC(tag: tag)
            }
            newTags.sort(by: BusinessCardTagMC.sortByPriority)
            DispatchQueue.main.async {
                self.tags = newTags
                self.delegate?.refreshData()
            }
        }
    }
}
