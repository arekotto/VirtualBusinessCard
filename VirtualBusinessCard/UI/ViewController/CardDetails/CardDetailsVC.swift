//
//  CardDetailsVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

final class CardDetailsVC: AppViewController<CardDetailsView, CardDetailsVM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
    }
    
}

extension CardDetailsVC: CardDetailsVMDelegate {
    
}
