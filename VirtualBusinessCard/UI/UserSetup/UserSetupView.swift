//
//  UserSetupView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 01/06/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct UserSetupView: AppSwiftUIView {
    typealias ViewModel = UserSetupViewModel
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            ActivityIndicator(isAnimating: $viewModel.isAnimatingActivityIndicator)
                .frame(width: 100, height: 100)
                .foregroundColor(Color.appAccent)
                .opacity(viewModel.isAnimatingActivityIndicator ? 1 : 0)
            Text(viewModel.title)
                .fontWeight(.bold)
                .font(.system(size: 24))
                .multilineTextAlignment(.center)
            Text(viewModel.subtitle)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(Edge.Set.vertical, 10)
        .padding(Edge.Set.horizontal, 20)
        .alert(isPresented: $viewModel.isErrorAlertPresented) {
            Alert(title: Text(viewModel.text.errorTitle), message: Text(viewModel.text.errorMessage), dismissButton: .default(Text(viewModel.text.retryButton), action: viewModel.setupUserInFirebase))
        }
        .onAppear() { self.viewModel.setupUserInFirebase() }
    }
}

struct UserSetupView_Previews: PreviewProvider {
    static var previews: some View {
        UserSetupView(viewModel: UserSetupViewModel(userID: "", email: ""))
    }
}
