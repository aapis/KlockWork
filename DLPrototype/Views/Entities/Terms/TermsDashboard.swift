//
//  TermDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-08-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct TermsDashboard: View {
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Terms")
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .background(.gray.opacity(0.2))
            .padding()
        }
        .background(Theme.toolbarColour)
    }
}
