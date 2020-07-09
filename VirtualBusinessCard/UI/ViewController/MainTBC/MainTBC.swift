//
//  MainTBC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

class MainTBC: UITabBarController {
        
    private(set) lazy var personalCardsVC = PersonalCardsCompactVC(viewModel: PersonalCardsVM(userID: userID))
    private(set) lazy var groupedCardsVC = GroupedCardsVC(viewModel: GroupedCardsVM(userID: userID))
    
    var allViewControllers: [UIViewController] {
        [personalCardsVC, groupedCardsVC]
    }
    
    private let userID: UserID
    
    init(userID: UserID) {
        self.userID = userID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        tabBar.shadowImage = UIColor.barSeparator.as1ptImage()
    }
    
    private func setupTabBarStyle() {
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



