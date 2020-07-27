//
//  GroupSharingVM.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 27/07/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import Foundation

protocol GroupSharingVMDelegate: class {

}

final class GroupSharingVM: AppViewModel {

    weak var delegate: GroupSharingVMDelegate?

}
