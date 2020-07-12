//
//  BusinessCardTag.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 25/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

typealias BusinessCardTagID = String

struct BusinessCardTag: Codable {
    var id: BusinessCardTagID
    var tagColor: TagColor
    var title: String
    var priorityIndex: Int
    var description: String?
    
    init(id: BusinessCardTagID, tagColor: TagColor, title: String, priorityIndex: Int, description: String? = nil) {
        self.id = id
        self.tagColor = tagColor
        self.title = title
        self.priorityIndex = priorityIndex
        self.description = description
    }
}

extension BusinessCardTag: Equatable {
    static func == (lhs: BusinessCardTag, rhs: BusinessCardTag) -> Bool {
        lhs.id == rhs.id
    }
}

extension BusinessCardTag: Firestoreable {
    
}

extension BusinessCardTag {
    enum TagColor: Int, Codable, CaseIterable {
        case red, green, gray, blue, pink, orange, teal, indigo, purple, yellow
    }
}
