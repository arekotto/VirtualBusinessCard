//
//  ContentView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 14/02/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    var body: some View {
        VStack {
            Button(action: {
                try! Auth.auth().signOut()
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
