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
    static let appBackground = UIColor(named: AppColorTheme.appBackground.rawValue)!
    static let appBackgroundSecondary = UIColor(named: AppColorTheme.appBackgroundSecondary.rawValue)!
    static let appGray = UIColor(named: AppColorTheme.appGray.rawValue)!
    static let appWhite = UIColor(named: AppColorTheme.appWhite.rawValue)!
    static let barSeparator = UIColor(named: AppColorTheme.barSeparator.rawValue)!
    static let appTabBar = UIColor(named: AppColorTheme.appTabBar.rawValue)!
    static let scrollableSegmentedControlSelectionBackground = UIColor(named:  AppColorTheme.scrollableSegmentedControlSelectionBackground.rawValue)!
    static let scrollableSegmentedControlSelectionText = UIColor(named:  AppColorTheme.scrollableSegmentedControlSelectionText.rawValue)!
    static let roundedTableViewCellBackground = UIColor(named:  AppColorTheme.roundedTableViewCellBackground.rawValue)!
    static let defaultText = UIColor(named:  AppColorTheme.defaultText.rawValue)!
    static let selectedCellBackgroundLight = UIColor(named:  AppColorTheme.selectedCellBackgroundLight.rawValue)!
    static let selectedCellBackgroundStrong = UIColor(named:  AppColorTheme.selectedCellBackgroundStrong.rawValue)!
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
    
    convenience init?(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return nil
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}

// MARK: - TagColor

extension UIColor {
    static func initFrom(tagColor: BusinessCardTag.TagColor) -> UIColor {
        switch tagColor {
        case .red: return .systemRed
        case .green: return .systemGreen
        case .gray: return .systemGray
        case .blue: return .systemBlue
        case .pink: return .systemPink
        case .orange: return .systemOrange
        case .teal: return .systemTeal
        case .indigo: return .systemIndigo
        case .purple: return .systemPurple
        case .yellow: return .systemYellow
        }
    }
}
