//
//  KeyboardHelper.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-14.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

open class KeyboardHelper {
    /// Determines if a given key was the Exc key
    /// - Parameter event: NSEvent
    /// - Returns: Bool
    static public func isEscapeKey(_ event: NSEvent) -> Bool {
        return Int(event.keyCode) == 53
    }
    
    /// Monitor for keyboard events
    /// Thank you https://blog.rampatra.com/how-to-detect-escape-key-pressed-in-macos-apps
    /// - Parameters:
    ///   - key: NSEvent.EventTypeMask
    ///   - callback: () -> Void
    /// - Returns: Void
    static public func monitor(key: NSEvent.EventTypeMask, callback: @escaping () -> Void) -> Void {
        NSEvent.addLocalMonitorForEvents(matching: key) {
            if KeyboardHelper.isEscapeKey($0) {
                callback()
                return nil
            } else {
                return $0
            }
        }
    }
}
