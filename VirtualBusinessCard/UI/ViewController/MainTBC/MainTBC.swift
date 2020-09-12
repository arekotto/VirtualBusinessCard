//
//  MainTBC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

class MainTBC: UITabBarController {

    private var didAppear = false

    private var selectedApplicationShortcut: ApplicationShortcut?

    private(set) lazy var personalCardsVC = PersonalCardsVC(viewModel: PersonalCardsVM(userID: userID))
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        if let shortcut = selectedApplicationShortcut {
            handleShortcut(shortcut)
            selectedApplicationShortcut = nil
        }
    }

    func setApplicationShortcut(_ shortcut: ApplicationShortcut) {
        if didAppear {
            handleShortcut(shortcut)
        } else {
            selectedApplicationShortcut = shortcut
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBar.tintColor = Asset.Colors.appAccent.color
        tabBar.backgroundColor = Asset.Colors.appTabBar.color
        tabBar.shadowImage = Asset.Colors.barSeparator.color.as1ptImage()
    }
    
    private func setupTabBarStyle() {
        tabBar.backgroundImage = UIImage.empty
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.shadowOpacity = 0.1
    }

    private func handleShortcut(_ shortcut: ApplicationShortcut) {
        if let presentedAppNavigationController = presentedViewController as? AppNavigationController {
            presentedAppNavigationController.dismissIfAppropriate(animated: false) { [unowned self] didDismiss in
                guard didDismiss else { return }
                self.executeShortcut(shortcut)
            }
        } else if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: false) { [unowned self] in
                self.executeShortcut(shortcut)
            }
        } else {
            executeShortcut(shortcut)
        }
    }

    private func executeShortcut(_ shortcut: ApplicationShortcut) {
        switch shortcut {
        case .search:
            guard let groupVCIndex = allViewControllers.firstIndex(of: groupedCardsVC) else { return }
            selectedIndex = groupVCIndex
            groupedCardsVC.navigationController?.popToRootViewController(animated: false)
            let vc = ReceivedCardsVC(viewModel: ReceivedCardsVM(userID: userID))
            vc.makeSearchFirstResponderOnNextAppearance = true
            if let selectedNC = selectedViewController as? UINavigationController {
                selectedNC.popToRootViewController(animated: false)
                selectedNC.pushViewController(vc, animated: true)
            }
        }
    }
}

extension MainTBC: AppUIStateRoot {
    var appUIState: AppUIState { .appContent }
}
