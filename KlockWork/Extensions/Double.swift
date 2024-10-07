//
//  Double.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-05-24.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Double {
#if os(iOS)
    var string: String {
        return String(format: "%.0f", self)
    }
#endif
}
