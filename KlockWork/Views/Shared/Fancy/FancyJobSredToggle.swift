//
//  FancyJobSredToggle.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct FancyJobSredToggle: View {
    public let entity: Job // TODO: should either be generic or not require a type
    public var label: String = "SR&ED Eligible"

    @State private var shredable: Bool = true

    var body: some View {
        HStack {
            VStack {
                FancyLabel(text: label)
            }
            HStack {
                Toggle(label, isOn: $shredable)
                Spacer()
            }
            .padding()
            .background(Theme.textBackground)
        }
        .onAppear(perform: {
            if entity.shredable {
                shredable = true
            } else {
                shredable = false
            }

            entity.shredable = shredable
        })
        .onChange(of: shredable) { bval in
            entity.shredable = bval
            PersistenceController.shared.save()
        }
    }
}
