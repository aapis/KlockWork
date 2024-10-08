//
//  View.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-23.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

#if os(macOS)
struct Swipe {}
#endif

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }

#if os(macOS)
    /// Hover effect, cursor changes to hand
    /// - Parameter onChange: (Bool) -> Void)
    /// - Returns: some View
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
    
    /// Hover effect without changing cursor
    /// - Parameter onChange: (Bool) -> Void)
    /// - Returns: some View
    func useDefaultHoverNoCursor(_ onChange: @escaping (Bool) -> Void) -> some View {
        self.onHover { inside in
            onChange(inside)
        }
    }
#endif

#if os(iOS)
    func swipe(_ swipe: Swipe, sensitivity: Double = 1, action: @escaping (Swipe) -> ()) -> some View {
        return gesture(DragGesture(minimumDistance: 30, coordinateSpace: .local)
            .onEnded { value in
                swipe.array.forEach { swipe in
                    if swipe.swiped(value, sensitivity) {
                        action(swipe)
                    }
                }
            }
        )
    }
#else
    func swipe(_ swipe: Swipe, sensitivity: Double = 1, action: @escaping (Swipe) -> ()) -> some View {
        return EmptyView()
    }
#endif
}
