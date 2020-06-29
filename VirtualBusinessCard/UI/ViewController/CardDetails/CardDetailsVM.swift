//
//  CardDetailsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

protocol CardDetailsVMDelegate: class {
    
}

final class CardDetailsVM: AppViewModel {
    
    weak var delegate: CardDetailsVMDelegate?
    
}
