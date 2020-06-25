//
//  Collection.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 22/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

extension Collection {
    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }
}
