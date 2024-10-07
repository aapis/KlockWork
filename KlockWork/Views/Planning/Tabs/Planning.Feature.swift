//
//  Planning.Feature.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Planning {
    struct Feature: View {
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text("Coming soon!")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                .background(Theme.rowColour)

                Spacer()
            }
        }
    }
}
