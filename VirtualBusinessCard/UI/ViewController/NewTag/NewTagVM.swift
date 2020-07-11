//
//  NewTagVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 11/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

protocol NewTagVMDelegate: class {
    
}

final class NewTagVM: AppViewModel {
    
    weak var delegate: NewTagVMDelegate?
    
}
