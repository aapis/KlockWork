//
//  ButtonType.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public enum ButtonType {
    case destructive, standard, primary, star, white, titleLink

    var colours: [Color] {
        switch self {
        case .primary:
            return [Color.green, Color.blue]
        case .destructive:
            return [Color.red, Color(hue: 0.0/100, saturation: 84.0/100, brightness: 43.0/100)]
        case .star:
            return [Color.yellow, Color.orange]
        case .standard:
            return [Theme.headerColour, Color.black]
        case .white:
            return [Color.white, Color.gray]
        case .titleLink:
            return [.clear, .clear]
        }
    }

    var textColour: Color {
        switch self {
        case .primary:
            return Color.white
        case .destructive:
            return Color.white
        case .star:
            return Color.black
        case .standard:
            return Color.white
        case .white:
            return Color.black
        case .titleLink:
            return Color.white
        }
    }

    var highlightColour: Color {
        switch self {
        case .primary:
            return Color.green
        case .destructive:
            return Color.red
        case .star:
            return Color.yellow
        case .standard:
            return Theme.headerColour
        case .white:
            return Color.gray
        case .titleLink:
            return Color.black
        }
    }

    var activeColour: Color {
        switch self {
        case .primary:
            return Theme.secondary
        case .destructive:
            return Theme.secondary
        case .star:
            return Theme.secondary
        case .standard:
            return Theme.secondary
        case .white:
            return Theme.secondary
        case .titleLink:
            return Theme.secondary
        }
    }
}
