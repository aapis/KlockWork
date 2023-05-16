//
//  FancyChip.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-05-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

enum ChipType {
    case green, yellow, red, standard
    
    var colour: Color {
        switch (self) {
        case .green:
            return Theme.rowStatusGreen
        case .yellow:
            return Color.yellow
        case .red:
            return Color.red
        case .standard:
            return Theme.textBackground
        }
    }
}

struct FancyChip: View {
    public var text: String
    public var type: ChipType = .standard
    public var icon: String = "multiply"
    public var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(text)
                    .font(Theme.font)
            }
        }
        .foregroundColor(type.colour.isBright() ? Color.black : Color.gray)
        .buttonStyle(.borderless)
        .padding(5)
        .background(type.colour)
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
