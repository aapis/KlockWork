//
//  Theme.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct Theme {
    static public var base: Color = Color(red: 0.1863933206, green: 0.1880253851, blue: 0.2143694162)
    static public var secondary: Color = Color.pink
    static public var rowColour: Color = Color.gray.opacity(0.2)
    static public var rowColourAsDouble: [Double] = [0.5, 0.5, 0.5, 0.2]
    static public var darkBtnColour: Color = Color.black.opacity(0.2)
    static public var headerColour: Color = Color.blue // TODO: allow colour change in settings?
    static public var subHeaderColour: Color = headerColour.opacity(0.2)
    static public var footerColour: Color = Color.gray.opacity(0.5)
    static public var toolbarColour: Color = Color.indigo.opacity(0.2)
    static public var tabColour: Color = Color.white.opacity(0.2)
    static public var tabActiveColour: Color = headerColour
    static public var rowStatusGreen: Color = Color.green.opacity(0.2)
    static public var rowStatusYellow: Color = Color.yellow.opacity(0.2)
    static public var rowStatusRed: Color = Color.red.opacity(0.2)
    static public var textBackground: Color = Color.black.opacity(0.1)
    static public let font: Font = .system(.body, design: .default)
    static public let fontTextField: Font = .system(.body, design: .monospaced)
    static public let fontTitle: Font = .system(.title, design: .monospaced)
    static public let fontSubTitle: Font = .system(.title3, design: .monospaced)
    static public let fontCaption: Font = .system(.caption, design: .monospaced)

    static public let cYellow: Color = .init(.sRGB, red: 0.34, green: 0.32, blue: 0.22, opacity: 1)
    static public let cRed: Color = .init(.sRGB, red: 0.34, green: 0.22, blue: 0.24, opacity: 1)
    static public let cGreen: Color = .init(.sRGB, red: 0.22, green: 0.34, blue: 0.32, opacity: 1)
    static public let cPurple: Color = .init(.sRGB, red: 0.34, green: 0.37, blue: 0.53, opacity: 1)
    static public let cOrange: Color = .init(.sRGB, red: 0.34, green: 0.26, blue: 0.22, opacity: 1)
}
