//
//  Color.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    static func random() -> Color {
        return Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
    }
    
    static public func fromStored(_ value: [Double]) -> Color {
        if value.count < 1 {
            return Theme.rowColour
        }
        
        var colour: Color

        if value.count == 3 {
            colour = Color(red: value[0], green: value[1], blue: value[2])
        } else {
            colour = Color(red: value[0], green: value[1], blue: value[2], opacity: value[3])
        }
        
        return colour
    }

    static func randomStorable() -> [Double] {
        return [Double.random(in: 0...1), Double.random(in: 0...1), Double.random(in: 0...1), 1.0]
    }

    static func lightGray() -> Color {
#if os(macOS)
        Color(nsColor: .lightGray)
#else
        Color(uiColor: .lightGray)
#endif
    }
    
    public func isBright() -> Bool {
        guard let components = cgColor?.components, components.count > 2 else {return false}
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return (brightness > 0.5)
    }

    public func toStored() -> [Double] {
        if let components = cgColor?.components {
            let r = components[0] * 1.0
            let g = components[1] * 1.0
            let b = components[2] * 1.0
            let a = components[3] * 1.0

            return [r,g,b,a]
        }

        return [0.0, 0.0, 0.0, 1.0]
    }
}
