//
//  FancyToggle.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct FancyToggle: View {
    public let entity: Project // TODO: should either be generic or not require a type
    public var label: String = "Active"

    @State private var alive: Bool = true

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
