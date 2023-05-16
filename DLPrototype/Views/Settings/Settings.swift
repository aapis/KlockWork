//
//  Settings.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, today, advanced
    }

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        TabView {
            GeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            
            TodaySettings()
                .tabItem {
                    Label("Today", systemImage: "doc.append.fill")
                }
                .tag(Tabs.today)
            
            DashboardSettings()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
                .tag(Tabs.today)
        }
        .padding(20)
    }
}

struct SettingsPreview: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
