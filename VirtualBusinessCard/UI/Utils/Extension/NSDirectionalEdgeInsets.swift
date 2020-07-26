//
//  NSDirectionalEdgeInsets.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 26/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension NSDirectionalEdgeInsets {
    init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}

extension UIEdgeInsets {
    init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}
