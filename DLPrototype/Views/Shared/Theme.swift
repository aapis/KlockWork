//
//  Theme.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Theme {
    static public var rowColour: Color = Color.gray.opacity(0.2)
    static public var rowColourAsDouble: [Double] = [0.5, 0.5, 0.5, 0.2]
    static public var darkBtnColour: Color = Color.black.opacity(0.2)
    static public var headerColour: Color = Color.blue
    static public var subHeaderColour: Color = headerColour.opacity(0.2)
    static public var footerColour: Color = Color.gray.opacity(0.5)
    static public var toolbarColour: Color = Color.indigo.opacity(0.2)
    static public var tabColour: Color = Color.white.opacity(0.2)
    static public var tabActiveColour: Color = headerColour
    static public var rowStatusGreen: Color = Color.green.opacity(0.2)
    static public var rowStatusRed: Color = Color.red.opacity(0.2)
    static public var textBackground: Color = Color.black.opacity(0.1)
    static public let font: Font = .system(.body, design: .monospaced)
    static public let fontTitle: Font = .system(.title, design: .monospaced)
    static public let fontSubTitle: Font = .system(.title3, design: .monospaced)
    static public let fontCaption: Font = .system(.caption, design: .monospaced)
}
