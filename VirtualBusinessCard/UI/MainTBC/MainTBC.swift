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
    let receivedBusinessCardsVC = ReceivedCardsVC(viewModel: ReceivedCardsVM())

    var allViewControllers: [UIViewController] {
        [personalBusinessCardsVC, receivedBusinessCardsVC]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = allViewControllers.map {
            let navigationController = AppNavigationController(rootViewController: $0)
            navigationController.title = $0.title
            return navigationController
        }
        
        setupTabBarStyle()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBar.tintColor = .appAccent
        tabBar.backgroundColor = .appTabBar
    }
    
    private func setupTabBarStyle() {
        tabBar.shadowImage = UIImage.empty
        tabBar.backgroundImage = UIImage.empty
        
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.shadowOpacity = 0.1
    }
}

extension MainTBC: AppUIStateRoot {
    var appUIState: AppUIState { .appContent }
}



