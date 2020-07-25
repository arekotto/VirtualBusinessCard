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
    
    func presentErrorAlert(title: String? = NSLocalizedString("Something Went Wrong", comment: ""), message: String = AppError.localizedUnknownErrorDescription, okActionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController.accentTinted(title: title, message: message, preferredStyle: .alert)
        alert.addOkAction(handler: okActionHandler)
        present(alert, animated: true)
    }

    func presentLoadingAlert() {
        let vc = SharingDataIndicatorVC(viewModel: AppViewModel(userID: viewModel.userID))
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}
