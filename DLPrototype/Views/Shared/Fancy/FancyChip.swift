//
//  FancyChip.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-05-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyChip: View {
    public var text: String
    public var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "multiply")
                Text(text)
                    .font(Theme.font)
            }
        }
        .buttonStyle(.borderless)
        .padding(5)
        .background(.black.opacity(0.2))
        .help(text)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}
