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
}

final class TagsVM: AppViewModel {
    
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
    
    func numberOfItems() -> Int {
        tags.count
    }
    
    func item(for indexPath: IndexPath) -> TagsView.TableCell.DataModel {
        let tag = tags[indexPath.row]
        return TagsView.TableCell.DataModel(
            tagName: tag.title,
            tagColor: tag.color,
            isFirstCell: indexPath.row == 0,
            isLastCell: indexPath.row == numberOfItems() - 1
        )
    }
    
    func didMoveItem(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tags.insert(tags.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
        delegate?.refreshData()
    }
    
    func didApproveEditing() {
        tags.enumerated().forEach { idx, tag in
            tag.priorityIndex = idx
        }
        tags.forEach {
            $0.save(in: tagsCollectionReference)
        }
        delegate?.refreshData()
    }
    
    func didCancelEditing() {
        tags.sort(by: Self.sortByPriority)
        delegate?.refreshData()
    }
}

// MARK: - Firebase fetch

extension TagsVM {
    private static func sortByPriority(_ lhs: BusinessCardTagMC, _ rhs: BusinessCardTagMC) -> Bool {
        lhs.priorityIndex < rhs.priorityIndex
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
        
        tags = querySnap.documents.compactMap {
            guard let tag = BusinessCardTag(queryDocumentSnapshot: $0) else {
                print(#file, "Error mapping business card:", $0.documentID)
                return nil
            }
            return BusinessCardTagMC(tag: tag)
        }.sorted(by: Self.sortByPriority)

        delegate?.refreshData()
    }
}
