//
//  CGSize.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import CoreGraphics

extension CGSize {

    static var businessCardAspectRatio: CGSize {
        CGSize(width: 85, height: 55)
    }

    static var businessCardHeightToWidthRatio: CGFloat { 55 / 85 }
    
    static func businessCardSize(width: CGFloat) -> CGSize {
        CGSize(width: width, height: width * businessCardHeightToWidthRatio)
    }
}
