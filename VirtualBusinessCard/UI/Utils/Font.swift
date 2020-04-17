//
//  Font.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import SwiftUI

//private enum AppColorTheme: String {
//    case appAccent = "AppAccent"
//    case appGray = "AppGray"
//}

extension UIFont {
//    static let AppDefalut = UIFont.system
}

extension Font {
    static func appDefault(size: CGFloat, weight: Weight = .regular, design: Design = .default) -> Font {
        system(size: size, weight: weight, design: design)
    }
    
    static func textSize(textStyle: UIFont.TextStyle) -> CGFloat {
       return UIFont.preferredFont(forTextStyle: textStyle).pointSize
    }
}
