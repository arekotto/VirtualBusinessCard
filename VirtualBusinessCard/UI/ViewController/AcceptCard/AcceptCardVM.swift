//
//  AcceptCardVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

protocol AcceptCardVMDelegate: class {

}

final class AcceptCardVM: AppViewModel {

    weak var delegate: AcceptCardVMDelegate?

    let card: ReceivedBusinessCardMC

    init(userID: UserID, sharedCard: ReceivedBusinessCardMC) {
        card = sharedCard
        super.init(userID: userID)
    }

}
