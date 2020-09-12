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
    
    var isShadowEnabled = false {
        didSet {
            if isShadowEnabled {
                navigationBar.shadowImage = Asset.Colors.barSeparator.color.as1ptImage()
                navigationBar.layer.shadowColor = UIColor.black.cgColor
                navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 0)
                navigationBar.layer.shadowRadius = 2
                navigationBar.layer.shadowOpacity = 0.07
            } else {
                navigationBar.shadowImage = UIImage.empty
                navigationBar.layer.shadowOpacity = 0
            }
        }
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setup()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        tabBarItem.title = nil
        if let tabBarDisplayableController = children.first as? TabBarDisplayable {
            tabBarItem.image = tabBarDisplayableController.tabBarIconImage
            tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
            children.first?.navigationItem.largeTitleDisplayMode = .always
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        navigationBar.isTranslucent = false
        isShadowEnabled = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBar.barTintColor = Asset.Colors.appBackground.color
        navigationBar.tintColor = Asset.Colors.appAccent.color
        toolbar.tintColor = Asset.Colors.appAccent.color
        view.backgroundColor = Asset.Colors.appBackground.color
        if isShadowEnabled {
            navigationBar.shadowImage = Asset.Colors.barSeparator.color.as1ptImage()
        }
    }

    func dismissIfAppropriate(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        if let presentedAppNC = presentedViewController as? AppNavigationController {
            presentedAppNC.dismissIfAppropriate(animated: false) { [unowned self] didDismiss in
                if didDismiss {
                    self.dismiss(animated: animated) {
                        completion?(true)
                    }
                } else {
                    completion?(false)
                }
            }
        } else {
            dismiss(animated: animated) {
                completion?(true)
            }
        }
    }
}
