//
//  AppViewController.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

class AppViewController<V: AppView, M: AppViewModel>: UIViewController {
    
    let viewModel: M
    var contentView: V {
        return view as! V
    }

    init(viewModel: M) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = V()
    }
}

extension AppViewController {

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
