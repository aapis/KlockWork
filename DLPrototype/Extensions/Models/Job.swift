//
//  Job.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Job {
    func id_int() -> Int {
        return Int(exactly: jid.rounded(.toNearestOrEven)) ?? 0
    }

    func id_string() -> String {
        return String(self.id_int())
    }

    func storedColour() -> Color {
        if let colour = self.colour {
            return Color.fromStored(colour)
        }

        return Color.clear
    }
}
