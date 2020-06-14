//
//  BusinessCardDetailsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 12/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

protocol BusinessCardDetailsVMDelegate: class {
    
}

final class BusinessCardDetailsVM: AppViewModel {
    
    weak var delegate: BusinessCardDetailsVMDelegate?
    
}
