//
//  ActivityWeight.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-06-12.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
//// import KWCore

/// Levels representing an amount of work
enum ActivityWeight: CaseIterable {
    case empty, light, medium, heavy, significant

    var colour: Color {
        switch self {
        case .empty: .clear
        case .light: Theme.rowColour
        case .medium: Theme.cYellow
        case .heavy: Theme.cRed
        case .significant: Theme.base
        }
    }

    var colourOpacity: Double {
        switch self {
        case .light: 0.2
        default: 1.0
        }
    }

    var label: String {
        switch self {
        case .empty: "Clear"
        case .light: "Light"
        case .medium: "Busy"
        case .heavy: "At Capacity"
        case .significant: "Overloaded"
        }
    }

    var defaultValue: Int64 {
        switch self {
        case .empty: 0
        case .light: 5
        case .medium: 10
        case .heavy: 15
        case .significant: 20
        }
    }

    var emoji: String {
        switch self {
        case .empty: "🏖️"
        case .light: "🙂"
        case .medium: "😶"
        case .heavy: "😡"
        case .significant: "🤬"
        }
    }

    // @TODO: localize
    var helpText: String {
        switch self {
        case .empty: "Little to no work"
        case .light: "Easily manageable"
        case .medium: "No time for tea"
        case .heavy: "That's it, no more!"
        case .significant: "FILE_NOT_FOUND"
        }
    }

    static func typeFromLabel(label: String) -> Self? {
        for w in Self.allCases {
            if w.label == label {
                return w
            }
        }

        return nil
    }
}
