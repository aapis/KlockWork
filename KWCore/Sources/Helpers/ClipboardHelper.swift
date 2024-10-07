//
//  ClipboardHelper.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-07.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
#if canImport(AppKit)
import AppKit


final public class ClipboardHelper {
    static public func copy(_ textToCopy: String) -> Void {
        let pasteBoard = NSPasteboard.general
        let data = textToCopy
        
        pasteBoard.clearContents()
        pasteBoard.setString(data, forType: .string)
    }
}

#endif
