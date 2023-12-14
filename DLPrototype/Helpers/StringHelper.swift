//
//  StringHelper.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public final class StringHelper {
    static public func abbreviate(_ data: String) -> String {
        let letters = data.split(separator: " ").map {$0.first!}

        // get the first 3 characters if there's only one word
        if letters.count == 1 {
            return String(data.prefix(4)).uppercased()
        }

        return String(letters).uppercased()
    }
}
