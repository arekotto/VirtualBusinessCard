//
//  AppView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 19/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

protocol AppView: View {
    associatedtype ViewModel: AppViewModel
    
    var viewModel: ViewModel {get set}
}
