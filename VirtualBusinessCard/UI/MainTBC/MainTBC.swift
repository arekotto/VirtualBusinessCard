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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [UINavigationController(rootViewController: personalBusinessCardsVC)]
    }
}

extension MainTBC: AppUIStateRoot {
    var appUIState: AppUIState { .appContent }
}
