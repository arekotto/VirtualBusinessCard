//
//  OrDivider.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 16/03/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI

struct OrDivider: View {
    var body: some View {
        HStack {
            VStack { Divider().background(Color.secondary).frame(height: 5) }
            Text("OR").foregroundColor(.secondary).font(.system(size: 16, weight: .light))
            VStack { Divider().background(Color.secondary) }
        }
        .padding(Edge.Set.horizontal, 40)
    }
}

struct OrDivider_Previews: PreviewProvider {
    static var previews: some View {
        OrDivider()
    }
}
