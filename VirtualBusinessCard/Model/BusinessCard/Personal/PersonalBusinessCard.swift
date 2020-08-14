//
//  PersonalBusinessCard.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 15/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

struct PersonalBusinessCard: Codable {
    var id: BusinessCardID
    var creationDate: Date
    var mostRecentPush: Date
    var mostRecentUpdate: Date
    var localizations: [BusinessCardLocalization]
}

extension PersonalBusinessCard: Equatable {
    static func == (lhs: PersonalBusinessCard, rhs: PersonalBusinessCard) -> Bool {
        lhs.id == rhs.id
    }
}

extension PersonalBusinessCard: Firestoreable {

}
