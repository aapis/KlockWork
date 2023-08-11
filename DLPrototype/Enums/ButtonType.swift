//
//  ButtonType.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public enum ButtonType {
    case destructive, standard, primary, secondary, star, white, titleLink, clear

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
        case .secondary:
            return [Theme.secondary, Color.black]
        case .white:
            return [Color.white, Color.gray]
        case .titleLink, .clear:
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
        case .standard, .secondary:
            return Color.white
        case .white:
            return Color.black
        case .titleLink, .clear:
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
        case .standard, .secondary:
            return Color.black
        case .white:
            return Color.gray
        case .titleLink, .clear:
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
        case .clear:
            return Theme.secondary
        case .secondary:
            return Theme.secondary
        }
    }
}
