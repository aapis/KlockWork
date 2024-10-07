//
//  Timestamp.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-05.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct Timestamp: View {
    public let text: String
    public var fullWidth: Bool = false
    public var alignment: Edge = .leading
    public var clear: Bool = false
    public var type: PageConfiguration.EntityType?

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if self.alignment == .trailing {
                Spacer()
            }
            HStack(spacing: 8) {
                if self.alignment == .leading {
                    if let type = self.type {
                        type.selectedIcon
                    }
                }
                Text(self.text)

                if self.alignment == .trailing {
                    if let type = self.type {
                        type.selectedIcon
                    }
                }
            }
            .padding(3)
            .background((self.clear ? Color.clear : Color.white.opacity(0.4)).blendMode(.softLight))
            .clipShape(.rect(cornerRadius: 3))

            if self.alignment == .leading {
                Spacer()
            }
        }
        .font(.system(.caption, design: .monospaced))
    }
}
