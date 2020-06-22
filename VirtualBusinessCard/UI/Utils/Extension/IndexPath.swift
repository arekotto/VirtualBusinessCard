//
//  IndexPath.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 21/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

extension IndexPath {
    
    /// Creates an index path that references an item in the first section.
    /// - Parameter item: index of item
    init(item: Int) {
        self.init(item: item, section: 0)
    }
}
