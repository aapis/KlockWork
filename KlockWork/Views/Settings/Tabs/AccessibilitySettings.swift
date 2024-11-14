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
            Spacer()
            Form {
                Section("User interface") {
                    Toggle("Show tab titles", isOn: $showTabTitles)
                    Toggle("Show hints & tutorials", isOn: $showUIHints)
                    Toggle("Show labels on buttons & dropdown menus", isOn: $showSelectorLabels)
                }
            }
            Spacer()
        }
        .padding(20)
        .onAppear(perform: self.actionOnAppear)
    }
}

extension AccessibilitySettings {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {

    }
}
