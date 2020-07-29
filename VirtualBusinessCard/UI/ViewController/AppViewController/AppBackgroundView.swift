//
//  AppBackgroundView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

class AppBackgroundView: AppView {
    
    override func configureColors() {
        super.configureColors()
        backgroundColor = Asset.Colors.appBackground.color
    }
}
