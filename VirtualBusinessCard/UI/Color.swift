//
//  Color.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import SwiftUI

private enum AppColorTheme: String {
    case appAccent = "AppAccent"
    case appGray = "AppGray"
    case googleBlue = "GoogleBlue"
    case microsoftBlue = "MicrosoftBlue"
}

extension UIColor {
    static let accent = UIColor(named: AppColorTheme.appAccent.rawValue)!
}

extension Color {
    static let appAccent = Color(AppColorTheme.appAccent.rawValue)
    static let appGray = Color(AppColorTheme.appGray.rawValue)
    static let googleBlue = Color(AppColorTheme.googleBlue.rawValue)
    static let microsoftBlue = Color(AppColorTheme.microsoftBlue.rawValue)
}
