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
        return String(data.split(separator: " ").map {$0.first!}).uppercased()
    }
}
