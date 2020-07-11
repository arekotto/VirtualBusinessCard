//
//  NewTagVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class NewTagVC: AppViewController<NewTagView, NewTagVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }
    
}

extension NewTagVC: NewTagVMDelegate {
    
}

