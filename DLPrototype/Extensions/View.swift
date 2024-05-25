//
//  View.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-23.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
#if os(macOS)
    func useDefaultHover(_ onChange: @escaping (Bool) -> Void) -> some View {
        self.onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
            
            onChange(inside)
        }
    }
#endif
}
