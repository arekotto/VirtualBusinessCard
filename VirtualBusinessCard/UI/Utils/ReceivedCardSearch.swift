//
//  ReceivedCardSearch.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/09/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

struct ReceivedCardSearch {

    static func receivedCard(localization: BusinessCardLocalization, matchesQuery query: String) -> Bool {
        receivedCardLocalization(name: localization.name, matchesQuery: query)
            || receivedCardLocalization(position: localization.position, matchesQuery: query)
            || receivedCardLocalization(address: localization.address, matchesQuery: query)
    }

    private static func receivedCardLocalization(name: BusinessCardLocalization.Name, matchesQuery query: String) -> Bool {
        [name.first, name.last, name.middle]
            .compactMap { $0 }
            .contains(where: { $0.localizedCaseInsensitiveContains(query) })
    }

    private static func receivedCardLocalization(address: BusinessCardLocalization.Address, matchesQuery query: String) -> Bool {
        [address.city, address.street, address.country]
            .compactMap { $0 }
            .contains(where: { $0.localizedCaseInsensitiveContains(query) })
    }

    private static func receivedCardLocalization(position: BusinessCardLocalization.Position, matchesQuery query: String) -> Bool {
        position.company?.localizedCaseInsensitiveContains(query) ?? false
    }

    private init() {}

}
