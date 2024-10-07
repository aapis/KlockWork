//
//  FancyToggle.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-08.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct FancyToggle: View {
    public let label: String
    public let value: Bool
    public let showLabel: Bool
    public let onChange: (Bool) -> Void

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
        .onChange(of: alive) { status in
            self.onChange(status)
        }
    }
}

struct FancyBoundToggle: View {
    public let label: String
    @Binding public var value: Bool
    public let showLabel: Bool
    public let onChange: (Bool) -> Void

    var body: some View {
        HStack {
            HStack {
                Toggle(showLabel ? label : "", isOn: $value)
                Spacer()
            }
            .padding()
            .background(Theme.textBackground)
        }
        .onChange(of: value) { status in
            self.onChange(status)
        }
    }
}
