//
//  BusinessCardTagMC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Firebase
import UIKit

final class BusinessCardTagMC {
        
    private let tag: BusinessCardTag
    
    var id: String { tag.id }
    
    var title: String { tag.title }
    
    var tagColor: BusinessCardTag.TagColor { tag.tagColor }
    
    var displayColor: UIColor {
        UIColor.initFrom(tagColor: tag.tagColor)
    }
    
    var priorityIndex: Int {
        tag.priorityIndex
    }
    
    var description: String? { tag.description }
    
    init(tag: BusinessCardTag) {
        self.tag = tag
    }
    
    func editBusinessCardTagMC() -> EditBusinessCardTagMC {
        EditBusinessCardTagMC(tag: tag)
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
