//
//  FancyJobActiveToggle.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct FancyJobActiveToggle: View {
    public let entity: Job // TODO: should either be generic or not require a type
    public var label: String = "Active"

    @State private var alive: Bool = true
    @FocusState private var focused: Bool

    var body: some View {
        HStack {
            VStack {
                FancyLabel(text: label)
            }
            HStack {
                Toggle(label, isOn: $alive)
                Spacer()
            }
            .padding()
            .background(Theme.textBackground)
            .focused($focused)
        }
        .onAppear(perform: {
            if entity.alive {
                alive = true
            } else {
                alive = false
            }

            entity.alive = alive

            PersistenceController.shared.save()
        })
    }
}
