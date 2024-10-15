//
//  LogTask.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-14.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension LogTask {
    var notificationBody: String {
        "\(self.content ?? "Unknown task") is due at \(self.due?.formatted() ?? "unclear, why do you ask?")"
    }
}
