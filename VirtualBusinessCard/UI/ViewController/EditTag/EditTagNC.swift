//
//  EditTagNC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 09/09/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditTagNC: AppNavigationController {

    var rootViewController: EditTagVC? {
        children.first as? EditTagVC
    }

    init(editTagVM: EditTagVM) {
        super.init(rootViewController: EditTagVC(viewModel: editTagVM))
    }

    override init() {
        fatalError("Use init(editTagVM:) instead.")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func dismissIfAppropriate(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard let editTagVC = rootViewController else {
            dismiss(animated: animated) {
                completion?(true)
            }
            return
        }

        editTagVC.presentDismissAlert(dismissAnimated: false, completion: completion)
    }
}
