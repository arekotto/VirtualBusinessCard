//
//  GroupedCardsVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 21/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

protocol GroupedCardsVMDelegate: class {
    
}

final class GroupedCardsVM: AppViewModel {
    
    weak var delegate: GroupedCardsVMDelegate?
    
}

extension GroupedCardsVM {
    var title: String {
        NSLocalizedString("Collection", comment: "")
    }
    
    var tabBarIconImage: UIImage {
        UIImage(named: "CollectionIcon")!
    }
}
