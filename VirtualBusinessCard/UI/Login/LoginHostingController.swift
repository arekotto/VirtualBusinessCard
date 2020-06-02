//
//  LoginHostingController.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

class LoginHostingController: UIHostingController<GreetingsView>, AppUIStateRoot {
    
    let appUIState = AppUIState.login
    
}
