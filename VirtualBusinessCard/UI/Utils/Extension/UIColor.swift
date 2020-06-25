//
//  UIColor.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension UIColor {
    static let appAccent = UIColor(named: AppColorTheme.appAccent.rawValue)!
    static let appDefaultBackground = UIColor(named: AppColorTheme.appDefaultBackground.rawValue)!
    static let appGray = UIColor(named: AppColorTheme.appGray.rawValue)!
    static let appWhite = UIColor(named: AppColorTheme.appWhite.rawValue)!
    static let barSeparator = UIColor(named: AppColorTheme.barSeparator.rawValue)!
    static let appTabBar = UIColor(named: AppColorTheme.appTabBar.rawValue)!
    static let scrollableSegmentedControlSelectionBackground = UIColor(named:  AppColorTheme.scrollableSegmentedControlSelectionBackground.rawValue)!
    static let scrollableSegmentedControlSelectionText = UIColor(named:  AppColorTheme.scrollableSegmentedControlSelectionText.rawValue)!
    static let roundedTableViewCellBackground = UIColor(named:  AppColorTheme.roundedTableViewCellBackground.rawValue)!
}

extension UIColor {

    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? .empty
        UIGraphicsEndImageContext()
        return image
    }
}
