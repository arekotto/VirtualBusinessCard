//
//  BusinessCardDetailsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class BusinessCardDetailsVC: AppViewController<BusinessCardDetailsView, BusinessCardDetailsVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
    }
    
}

extension BusinessCardDetailsVC: BusinessCardDetailsVMDelegate {
    
}
