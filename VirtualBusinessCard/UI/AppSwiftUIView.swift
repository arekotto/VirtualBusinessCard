//
//  AppSwiftUIView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 19/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

protocol AppSwiftUIView: View {
    associatedtype ViewModel: AppSwiftUIViewModel
    
    var viewModel: ViewModel {get set}
}
