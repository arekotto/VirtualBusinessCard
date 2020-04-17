//
//  DeviceDisplay.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 19/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

struct DeviceDisplay {
    
    enum TargetUIType {
        case compact
        case standard
        case commodious
    }
    
    static var size: CGSize {
        UIScreen.main.bounds.size
    }
    
    static var sizeType: TargetUIType {
        if size.width <= 320 {
            return .compact
        } else if size.width >= 414 {
            return .commodious
        }
        return .standard
    }
}
