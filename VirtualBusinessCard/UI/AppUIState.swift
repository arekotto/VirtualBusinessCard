//
//  AppUIState.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 02/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit

enum AppUIState {
    case login
    case appContent
}

protocol AppUIStateRoot: UIViewController {
    var appUIState: AppUIState { get }
}
