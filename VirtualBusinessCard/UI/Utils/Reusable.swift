//
//  Reusable.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 22/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

protocol Reusable: class {
    static var reuseId: String { get }
}

extension Reusable {
    static var reuseId: String {
        String(describing: self)
    }
}
