//
//  BusinessCardTagMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import UIKit

class BusinessCardTagMC {
    
    let storage = Storage.storage().reference()
    
    private var tag: BusinessCardTag
    
    var id: String { tag.id }
    
    var title: String { tag.title }
    
    var colorHex: String { tag.colorHex }
    
    var priorityIndex: Int {
        get { tag.priorityIndex }
        set { tag.priorityIndex = newValue }
    }
    
    var description: String? { tag.description }
    
    var color: UIColor {
        UIColor(hex: tag.colorHex) ?? .clear
    }
    
    init(tag: BusinessCardTag) {
        self.tag = tag
    }
}

extension BusinessCardTagMC {
    convenience init?(userPublicDocument: DocumentSnapshot) {
        guard let tag = BusinessCardTag(documentSnapshot: userPublicDocument) else { return nil }
        self.init(tag: tag)
    }
}

extension BusinessCardTagMC: Equatable {
    static func == (lhs: BusinessCardTagMC, rhs: BusinessCardTagMC) -> Bool {
        lhs.tag == rhs.tag
    }
}

// MARK: - Saving

extension BusinessCardTagMC {
    
    func save(in collectionReference: CollectionReference) {
        collectionReference.document(tag.id).setData(tag.asDocument())
    }
}
