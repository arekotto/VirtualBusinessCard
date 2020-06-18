//
//  AppNavigationController.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 18/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

class AppNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        let separator = UIColor.barSeparator.as1ptImage()
        navigationBar.shadowImage = separator
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.barTintColor = .appDefaultBackground
        navigationBar.tintColor = .appAccent
        view.backgroundColor = .appDefaultBackground
    }
}
