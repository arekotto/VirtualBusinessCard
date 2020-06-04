//
//  SingletonFirestoreable.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 04/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

protocol SingletonFirestoreable: Firestoreable {
    static var documentName: String {get}
}
