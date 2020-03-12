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
    case accent = "Accent"
}

extension UIColor {
    static let accent = UIColor(named: AppColorTheme.accent.rawValue)
}

extension Color {
    static let accent = Color(AppColorTheme.accent.rawValue)
}
