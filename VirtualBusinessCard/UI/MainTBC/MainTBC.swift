//
//  MainTBC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

class MainTBC: UITabBarController {
    
    let personalBusinessCardsVC = PersonalBusinessCardsVC(viewModel: PersonalBusinessCardsVM())
    
    var allViewControllers: [UIViewController] {
        [personalBusinessCardsVC]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = allViewControllers.map {
            let navigationController = UINavigationController(rootViewController: $0)
            navigationController.navigationBar.prefersLargeTitles = true
            return navigationController
        }
    }
}

extension MainTBC: AppUIStateRoot {
    var appUIState: AppUIState { .appContent }
}
