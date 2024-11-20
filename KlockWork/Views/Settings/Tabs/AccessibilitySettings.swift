//
//  AccessibilitySettings.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-27.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct AccessibilitySettings: View {
    @EnvironmentObject public var state: Navigation
    @AppStorage("settings.accessibility.showTabTitles") private var showTabTitles: Bool = true
    @AppStorage("settings.accessibility.showUIHints") private var showUIHints: Bool = true
    @AppStorage("settings.accessibility.showSelectorLabels") private var showSelectorLabels: Bool = true

    var body: some View {
        HStack {
            Text("All migrated")
        }
        .frame(width: 900)
        .padding(20)
    }
}

extension AccessibilitySettings {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {

    }
}
