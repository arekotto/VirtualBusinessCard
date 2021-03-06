//
//  CreateAccountView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 20/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct CreateAccountView: AppSwiftUIView {
    typealias ViewModel = CreateAccountViewModel
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: CreateAccountNameView(viewModel: viewModel.createAccountNameViewModel()), tag: .createAccountWithEmail, selection: $viewModel.navSelection) {
                    EmptyView()
                }
                bodyMain
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: viewModel.closeButtonTapped) {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        .font(.system(size: 20, weight: .bold))
                        .padding(12)
                }
                .background(Color.appAccent.opacity(0.1))
                .clipShape(Circle())
            )
            .background(NavigationConfigurator { nc in
                nc.navigationBar.standardAppearance.configureWithTransparentBackground()
            })
        }
        .accentColor(Color.appAccent)
    }
    
    var bodyMain: some View {
        VStack(spacing: 10) {
            Text(viewModel.text.title)
                .fontWeight(.bold)
                .font(.system(size: 24))
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
            VStack(spacing: 20) {
                loginWithMicrosoftButton
                loginWithGoogleButton
                loginWithAppleButton
                OrDivider()
                loginWithEmailButton
            }
            .padding(Edge.Set.vertical, 20)
        }
        .padding(Edge.Set.vertical, 10)
        .padding(Edge.Set.horizontal, 20)
    }
    
    var loginWithGoogleButton: some View {
        Button(action: viewModel.didTapLoginWithGoogle) {
            LoginWithGoogleButton(title: viewModel.text.continueWithGoogleButton)
        }
        .buttonStyle(ShrinkOnTapButtonStyle())
    }
    
    var loginWithMicrosoftButton: some View {
        Button(action: viewModel.didTapLoginWithMicrosoft) {
            LoginWithMicrosoftButton(title: viewModel.text.continueWithMicrosoftButton)
        }
        .buttonStyle(ShrinkOnTapButtonStyle())
    }
    
    var loginWithAppleButton: some View {
        Button(action: viewModel.didTapLoginWithApple) {
            LoginWithAppleButton(title: viewModel.text.continueWithAppleButton)
        }
        .buttonStyle(ShrinkOnTapButtonStyle())
    }
    
    var loginWithEmailButton: some View {
        Button(action: viewModel.didTapLoginWithEmail) {
            Text(viewModel.text.continueWithEmailButton)
                //                    .frame(maxWidth: .infinity)
                .frame(height: 54)
        }
        .buttonStyle(AppDefaultButtonStyle())
    }
    
    init(viewModel: CreateAccountViewModel) {
        self.viewModel = viewModel
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateAccountView(viewModel: CreateAccountViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .dark)
            
            CreateAccountView(viewModel: CreateAccountViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
            
            CreateAccountView(viewModel: CreateAccountViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
                .previewDisplayName("iPhone Xs")
                .environment(\.colorScheme, .dark)
            
            CreateAccountView(viewModel: CreateAccountViewModel(isPresented: .constant(true)))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }
}
