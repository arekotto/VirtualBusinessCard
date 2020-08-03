//
//  EditCardInfoVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 03/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardInfoVC: AppViewController<EditCardInfoView, EditCardInfoVM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }

}

extension EditCardInfoVC: EditCardInfoVMDelegate {

}
