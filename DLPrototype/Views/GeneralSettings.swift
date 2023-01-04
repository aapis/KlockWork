//
//  GeneralSettingsView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct GeneralSettings: View {
    @AppStorage("tigerStriped") private var tigerStriped: Bool = false
    @AppStorage("defaultTableSortOrder") private var defaultTableSortOrder: String = "DESC"
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures: Bool = false
    @AppStorage("showExperiment.actions") private var showExperimentActions: Bool = false
    @AppStorage("enableAutoCorrection") public var enableAutoCorrection: Bool = false

    var body: some View {
        Form {
            Toggle("Tiger stripe table rows", isOn: $tigerStriped)
            Toggle("Auto-correct text in text boxes", isOn: $enableAutoCorrection)
            
            Group {
                Toggle("Experimental features (may tank performance)", isOn: $showExperimentalFeatures)
                
                if showExperimentalFeatures {
                    Toggle("Show row actions", isOn: $showExperimentActions)
                }
            }
            
            Picker("Default table sort direction:", selection: $defaultTableSortOrder) {
                Text("DESC").tag("DESC")
                Text("ASC").tag("ASC")
            }
        }
        .padding(20)
        .frame(width: 350, height: 100)
    }
}

struct GeneralSettingsPreview: PreviewProvider {
    static var previews: some View {
        GeneralSettings()
    }
}
