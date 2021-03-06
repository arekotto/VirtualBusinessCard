//
//  UIBarButtonItem.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 10/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    static func done(target: Any?, action: Selector?) -> UIBarButtonItem {
        UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: target, action: action)
    }

    static func cancel(target: Any?, action: Selector?) -> UIBarButtonItem {
        UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: target, action: action)
    }

    static func add(target: Any?, action: Selector?) -> UIBarButtonItem {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: imageConfig)!
        return UIBarButtonItem(image: image, style: .plain, target: target, action: action)
    }
}
