//
//  DetailsColumn.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct DetailsColumn: View {
    public var colour: Color
    public var textColour: Color
    public var index: Array<Entry>.Index?

    @Binding public var text: String

    @AppStorage("tigerStriped") private var tigerStriped = false

    var body: some View {
        HStack(spacing: 1) {
            ZStack(alignment: .leading) {
                Theme.rowColour

                Text("key")
                    .padding(10)
            }

            ZStack(alignment: .leading) {
                Theme.rowColour

                Text("Value")
                    .padding(10)
            }
        }
    }
}
