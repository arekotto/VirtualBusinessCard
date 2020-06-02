//
//  SceneDelegate.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 14/02/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    private var statePresented: AppUIState? {
        (window?.rootViewController as? AppUIStateRoot)?.appUIState
    }
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        authStateListenerHandle = Auth.auth().addStateDidChangeListener(authStateDidChange)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = rootViewControllerBasedOnAuthState()
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}

    // MARK: Authentication

    private func authStateDidChange(_ auth: Auth?, _ user: Firebase.User?) {
        if let usr = user {
            print("LOGGED IN USER " + (usr.displayName ?? usr.email ?? usr.providerID))
            hideLogin()
        } else {
            displayLogin()
        }
    }
    
    private func hideLogin() {
        switch statePresented {
        case .login, .none:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let rootVC = self.rootViewControllerBasedOnAuthState()
                self.swapRootControllerWithAnimation(rootVC, animation: .transitionFlipFromRight)
            }
        case .appContent:
            // No action needed
            return
        }
    }
    
    private func displayLogin() {
        switch statePresented {
        case .appContent, .none:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let rootVC = self.rootViewControllerBasedOnAuthState()
                self.swapRootControllerWithAnimation(rootVC, animation: .transitionFlipFromRight)
            }
        case .login:
            // No action needed
            return
        }
    }
    
    private func rootViewControllerBasedOnAuthState() -> UIViewController {
        if isUserLoggedIn {
//            return UIHostingController(rootView: ContentView(viewModel: ContentViewModel()))
//            let vc = UITabBarController()
//            vc.setViewControllers([
//                UINavigationController(rootViewController: SceneVC()),
//                UINavigationController(rootViewController: BusinessCardTVC())],
//            animated: false)
//            return vc
            return MainTBC()
        } else {
            return LoginHostingController(rootView: GreetingsView())
        }
    }
    
    private func swapRootControllerWithAnimation(_ newRoot: UIViewController, animation: UIView.AnimationOptions) {
        UIView.transition(with: window!, duration: 0.5, options: animation, animations: {
            self.window!.rootViewController = newRoot
        }, completion: { completed in
            // TODO: - REMEBER TO CHECK MEMORY LEAKSSSS
        })
    }
}


