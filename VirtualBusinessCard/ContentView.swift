//
//  ContentView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 14/02/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    var body: some View {
        VStack {
            Button(action: {
            }) {
                Text("Log out!")
            }
        }
        .background(Color.green)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LoginView: View {
    var body: some View {
        VStack {
            Button(action: {
            }) {
                Text("Log in!")
            }
        }
        .background(Color.yellow)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
