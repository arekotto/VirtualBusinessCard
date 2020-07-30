//
//  LoadingPopoverVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 24/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class LoadingPopoverVC: AppViewController<LoadingPopoverView, LoadingPopoverVM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.titleLabel.text = viewModel.title
    }
}
