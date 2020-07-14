//
//  UIFont.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension UIFont {
    static func appDefault(size: CGFloat, weight: Weight = .regular, design: UIFontDescriptor.SystemDesign = .default) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)

        guard let descriptor = systemFont.fontDescriptor.withDesign(design) else {
            return systemFont
        }
        
        return UIFont(descriptor: descriptor, size: size)
    }
}
