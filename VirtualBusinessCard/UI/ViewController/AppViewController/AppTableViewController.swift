//
//  AppTableViewController.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 08/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

class AppTableViewController<M: AppViewModel>: UITableViewController {

    let viewModel: M

    init(viewModel: M, style: UITableView.Style) {
        self.viewModel = viewModel
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
