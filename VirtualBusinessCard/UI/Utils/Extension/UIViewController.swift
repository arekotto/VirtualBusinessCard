//
//  UIViewController.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

extension UIViewController {

    private static var defaultTitle: String {
        NSLocalizedString("Something Went Wrong", comment: "")
    }

    func presentErrorAlert(title: String? = defaultTitle, message: String = AppError.localizedUnknownErrorDescription, okActionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = AppAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addOkAction(handler: okActionHandler)
        present(alert, animated: true)
    }

    func presentLoadingAlert(title: String) {
        let vc = LoadingPopoverVC(title: title)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    func presentDismissAlert(dismissAnimated: Bool, completion: ((_: Bool) -> Void)? = nil ) {
        let title = NSLocalizedString("Are you sure you want to discard?", comment: "")
        let alert = AppAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { [unowned self] _ in
            self.dismiss(animated: dismissAnimated) {
                completion?(true)
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Keep Editing", comment: ""), style: .cancel) { _ in
            completion?(false)
        })
        present(alert, animated: true)
    }
}
