//
//  UIAlertController.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 29/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class AppAlertController: UIAlertController {

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.tintColor = Asset.Colors.appAccent.color
    }

    func addCancelAction() {
        addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
    }

    func addOkAction(handler: ((UIAlertAction) -> Void)? = nil) {
        addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { action in
            handler?(action)
        })
    }
}
