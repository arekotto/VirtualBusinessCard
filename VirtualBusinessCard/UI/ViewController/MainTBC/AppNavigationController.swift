//
//  AppNavigationController.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 18/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol TabBarDisplayable {
    var tabBarIconImage: UIImage { get }
}

class AppNavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        tabBarItem.title = nil
        if let tabBarDisplayableController = rootViewController as? TabBarDisplayable {
            tabBarItem.image = tabBarDisplayableController.tabBarIconImage
            tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
            rootViewController.navigationItem.largeTitleDisplayMode = .always
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage.empty
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.barTintColor = .appDefaultBackground
        navigationBar.tintColor = .appAccent
        view.backgroundColor = .appDefaultBackground
    }
}
