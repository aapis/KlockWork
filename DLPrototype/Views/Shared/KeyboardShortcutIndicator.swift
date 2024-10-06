//
//  KeyboardShortcutIndicator.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-05.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct KeyboardShortcutIndicator: View {
    public var character: String
    public var requireShift: Bool = false
    public var requireCmd: Bool = true

    var body: some View {
        HStack(alignment: .top, spacing: 2) {
            if self.requireShift { Image(systemName: "arrowshape.up") }
            if self.requireShift { Image(systemName: "command") }
            Text(self.character)
        }
        .help("\(self.requireShift ? "Shift+" : "")\(self.requireCmd ? "Command+" : "")\(self.character)")
        .foregroundStyle(.white.opacity(0.55))
        .font(.caption)
        .padding(3)
        .background(.white.opacity(0.4).blendMode(.softLight))
        .clipShape(.rect(cornerRadius: 4))
    }
}
