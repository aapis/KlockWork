//
//  View.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-23.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    public func saveable(title: String) -> Bool {
        if title == "Notes" {
            return false
        }

        return true
    }
}
