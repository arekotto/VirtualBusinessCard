//
//  GroupSharingVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 27/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class GroupSharingVC: AppViewController<GroupSharingView, GroupSharingVM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }

}

extension GroupSharingVC: GroupSharingVMDelegate {

}
