//
//  DefaultCompanySidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct DefaultCompanySidebar: View {
    @State public var date: Date = Date()

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Coming soon")
            }
            Spacer()
        }
        .padding()
    }
}
