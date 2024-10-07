//
//  ButtonType.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

public enum ButtonSize {
    case small, medium, large, link, titleLink, tiny, tinyLink

    var width: CGFloat {
        switch self {
        case .tiny:
            return 10
        case .link:
            return .infinity
        case .titleLink, .tinyLink:
            return 20
        case .small:
            return 40
        case .medium, .large:
            return 200
        }
    }

    var padding: CGFloat {
        return switch self {
        case .tiny, .link, .tinyLink: 3
        case .small, .medium, .large, .titleLink: 5
        }
    }

    var height: CGFloat {
        switch self {
        case .tiny:
            return 10
        case .link, .tinyLink:
            return 20
        case .small, .medium, .large, .titleLink:
            return 40
        }
    }

    var font: Font {
        switch self {
        case .tiny, .link, .small, .tinyLink:
            return .body
        case .medium, .large:
            return .title3
        case .titleLink:
            return Theme.fontTitle
        }
    }
}
