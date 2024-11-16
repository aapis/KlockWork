//
//  GlobalSettingsPanel.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-11-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct GlobalSettingsPanel: View {
    @State private var tabs: [ToolbarButton] = []

    var body: some View {
        FancyGenericToolbar(
            buttons: self.tabs,
            standalone: true,
            location: .sidebar,
            mode: .compact,
            page: .find,
            scrollable: false
        )
    }
}
