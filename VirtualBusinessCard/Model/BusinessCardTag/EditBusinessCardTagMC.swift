//
//  EditBusinessCardTagMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import UIKit

final class EditBusinessCardTagMC {
    
    static private let unsavedObjectID = ""
    
    private var tag: BusinessCardTag
    
    var id: String {
        get { tag.id }
        set { tag.id  = newValue }
    }
    
    var title: String {
        get { tag.title }
        set { tag.title = newValue }
    }
    
    var tagColor: BusinessCardTag.TagColor {
        get { tag.tagColor }
        set { tag.tagColor = newValue }
    }
    
    @objc var priorityIndex: Int {
        get { tag.priorityIndex }
        set { tag.priorityIndex = newValue }
    }
    
    var description: String? { tag.description }
    
    var displayColor: UIColor {
        UIColor.initFrom(tagColor: tag.tagColor)
    }
    
    init(tag: BusinessCardTag) {
        self.tag = tag
    }
    
    func businessCardTagMC() -> BusinessCardTagMC {
        BusinessCardTagMC(tag: tag)
    }
}

extension EditBusinessCardTagMC {
    
    convenience init(estimatedLowestPriorityIndex: Int, color: BusinessCardTag.TagColor = .blue) {
        self.init(tag: BusinessCardTag(id: Self.unsavedObjectID, tagColor: color, title: "", priorityIndex: estimatedLowestPriorityIndex))
    }

    convenience init?(userPublicDocument: DocumentSnapshot) {
        guard let tag = BusinessCardTag(documentSnapshot: userPublicDocument) else { return nil }
        self.init(tag: tag)
    }
}

// MARK: - Saving

extension EditBusinessCardTagMC {
    func save(in collectionReference: CollectionReference, completion: ((Result<Void, Error>) -> Void)? = nil) {
        
        let docRef: DocumentReference
        if tag.id == Self.unsavedObjectID {
            docRef = collectionReference.document()
            tag.id = docRef.documentID
        } else {
            docRef = collectionReference.document(tag.id)
        }
        
        docRef.setData(tag.asDocument()) { error in
            if let err = error {
                print(err.localizedDescription)
                completion?(.failure(err))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    func savePriorityIndex(in collectionReference: CollectionReference) {
        collectionReference.document(tag.id).updateData([#keyPath(EditBusinessCardTagMC.priorityIndex): priorityIndex])
    }
    
    func delete(in collectionReference: CollectionReference, completion: ((Result<Void, Error>) -> Void)? = nil) {
        collectionReference.document(tag.id).delete { error in
            if let err = error {
                print(err.localizedDescription)
                completion?(.failure(err))
            } else {
                completion?(.success(()))
            }
        }
    }
}
