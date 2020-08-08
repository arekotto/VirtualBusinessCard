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

    func presentLoadingAlert(viewModel: LoadingPopoverVM) {
        let vc = LoadingPopoverVC(viewModel: viewModel)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    func presentDismissAlert() {
        let title = NSLocalizedString("Are you sure you want to discard?", comment: "")
        let alert = AppAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
            self.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Keep Editing", comment: ""), style: .cancel))
        present(alert, animated: true)
    }
}
