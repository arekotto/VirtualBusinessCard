//
//  TagsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 10/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import UIKit

protocol TagsVMDelegate: class {
    func refreshData()
    func presentNewTagVC(with viewModel: EditTagVM)
}

final class TagsVM: PartialUserViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<TagsVM.Section, TagTableCell.DataModel>

    weak var delegate: TagsVMDelegate?
    
    private var tags = [BusinessCardTagMC]()

}

// MARK: - ViewController API

extension TagsVM {
    var title: String {
        NSLocalizedString("Tags", comment: "")
    }
    
    var newTagImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        return UIImage(systemName: "plus.circle.fill", withConfiguration: imgConfig)!
    }
    
    var sortControlImage: UIImage {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        return UIImage(systemName: "arrow.up.arrow.down", withConfiguration: imgConfig)!
    }
    
    var doneEditingButtonTitle: String {
        NSLocalizedString("Done", comment: "")
    }
    
    var cancelEditingButtonTitle: String {
        NSLocalizedString("Cancel", comment: "")
    }

    func dataSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(tags.enumerated().map { index, tag in
            TagTableCell.DataModel(itemNumber: index, tagName: tag.title, tagColor: tag.displayColor)
        })
        return snapshot
    }

    func didSelectItem(at indexPath: IndexPath) {
        let editTag = tags[indexPath.row].editBusinessCardTagMC()
        delegate?.presentNewTagVC(with: EditTagVM(userID: userID, editBusinessCardTagMC: editTag))
    }
    
    func didMoveItem(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tags.insert(tags.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
        delegate?.refreshData()
    }
    
    func didApproveEditing() {
        DispatchQueue.global().async {
            let editableTags = self.tags.map { $0.editBusinessCardTagMC() }
            editableTags.enumerated().forEach { idx, tag in
                tag.priorityIndex = idx
            }
            editableTags.forEach {
                $0.save(in: self.tagsCollectionReference, fields: [.priorityIndex])
            }
            let newTags = editableTags.map { $0.businessCardTagMC() }
            DispatchQueue.main.async {
                self.tags = newTags
                self.delegate?.refreshData()
            }
        }
    }
    
    func didCancelEditing() {
        tags.sort(by: BusinessCardTagMC.sortByPriority)
        delegate?.refreshData()
    }
    
    func didSelectNewTag() {
        delegate?.presentNewTagVC(with: EditTagVM(userID: userID, estimatedLowestPriorityIndex: tags.count))
    }
}

// MARK: - Firebase fetch

extension TagsVM {
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

// MARK: - Section

extension TagsVM {
    enum Section {
        case main
    }
}
