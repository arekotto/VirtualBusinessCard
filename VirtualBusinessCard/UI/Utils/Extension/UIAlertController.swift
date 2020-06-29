//
//  UIAlertController.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 29/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func withTint(title: String?, message: String?, preferredStyle: UIAlertController.Style) -> UIAlertController {
        let ac = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        ac.view.tintColor = .appAccent
        return ac
    }
}

