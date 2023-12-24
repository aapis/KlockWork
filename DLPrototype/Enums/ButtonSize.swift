//
//  ButtonType.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public enum ButtonSize {
    case small, medium, large, link, titleLink, tiny

    var width: CGFloat {
        switch self {
        case .tiny:
            return 10
        case .link:
            return .infinity
        case .titleLink:
            return 20
        case .small:
            return 40
        case .medium, .large:
            return 200
        }
    }

    var padding: CGFloat {
        switch self {
        case .tiny, .link:
            return 3
        case .small, .medium, .large, .titleLink:
            return 5
        }
    }

    var height: CGFloat {
        switch self {
        case .tiny:
            return 10
        case .link:
            return 20
        case .small, .medium, .large, .titleLink:
            return 40
        }
    }

    var font: Font {
        switch self {
        case .tiny, .link, .small:
            return .body
        case .medium, .large:
            return .title3
        case .titleLink:
            return Theme.fontTitle
        }
    }
}
