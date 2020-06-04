//
//  ModelController.swift
//  BillShare
//
//  Created by Arek Otto on 07/04/2019.
//  Copyright © 2019 Arek Otto. All rights reserved.
//

import Foundation

protocol ModelController {
    associatedtype Model: Firestoreable
    
    var id: String { get }
    
    func isModelEqual(to: Model) -> Bool
    func asDocument() -> [String: Any]
    func save()
}
