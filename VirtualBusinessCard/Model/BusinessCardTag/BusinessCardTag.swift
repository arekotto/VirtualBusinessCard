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
    var color: String
    var title: String
    var priorityIndex: Int
    var description: String?
}

extension BusinessCardTag: Equatable {
    static func == (lhs: BusinessCardTag, rhs: BusinessCardTag) -> Bool {
        lhs.id == rhs.id
    }
}

extension BusinessCardTag: Firestoreable {
    
}
