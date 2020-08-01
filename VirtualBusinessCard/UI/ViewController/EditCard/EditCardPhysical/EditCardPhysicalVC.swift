//
//  EditCardPhysicalVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/08/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class EditCardPhysicalVC: AppViewController<EditCardPhysicalView, EditCardPhysicalVM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }

}

extension EditCardPhysicalVC: EditCardPhysicalVMDelegate {

}
