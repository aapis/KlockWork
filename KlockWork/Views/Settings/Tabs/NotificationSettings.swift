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
            Picker("Notification intervals", selection: $notificationInterval) {
                Text("1 hour prior").tag(1)
                Text("1 hour & 15 minutes prior").tag(2)
                Text("1 hour, 15 minutes, and 5 minutes prior").tag(3)
                Text("15 minutes prior").tag(4)
                Text("5 minutes prior").tag(5)
                Text("15 minutes & 5 minutes prior").tag(6)
            }
        }
        .padding(20)
        .onAppear(perform: self.actionOnAppear)
    }
}

extension NotificationSettings {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {

    }
}
