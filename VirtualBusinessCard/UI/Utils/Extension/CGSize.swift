//
//  CGSize.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import CoreGraphics

extension CGSize {
    
    static var businessCardSizeRatio: CGFloat { 55 / 85 }
    
    static func businessCardSize(width: CGFloat) -> CGSize {
        CGSize(width: width, height: width * businessCardSizeRatio)
    }
}
