//
//  FancyToggle.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-08.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct FancyToggle: View {
    public let label: String
    public let value: Bool
    public let showLabel: Bool = false

    @State private var alive: Bool = false

    var body: some View {
        HStack {
            HStack {
                Toggle(showLabel ? label : "", isOn: $alive)
                Spacer()
            }
            .padding()
            .background(Theme.textBackground)
        }
        .onAppear(perform: {
            alive = value
        })
    }
}
