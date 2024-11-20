//
//  NotificationSettings.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-14.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct NotificationSettings: View {
    @EnvironmentObject public var state: Navigation
    @AppStorage("notifications.interval") private var notificationInterval: Int = 0

    var body: some View {
        Form {
            Text("All migrated")
        }
        .frame(width: 900)
        .padding(20)
    }
}

extension NotificationSettings {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {

    }
}
