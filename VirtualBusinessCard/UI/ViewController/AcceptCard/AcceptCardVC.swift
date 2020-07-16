//
//  AcceptCardVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

final class AcceptCardVC: AppViewController<AcceptCardView, AcceptCardVM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }

}

extension AcceptCardVC: AcceptCardVMDelegate {

}
