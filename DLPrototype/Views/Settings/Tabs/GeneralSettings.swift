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
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures: Bool = false
    @AppStorage("enableAutoCorrection") public var enableAutoCorrection: Bool = false
    @AppStorage("autoFixJobs") public var autoFixJobs: Bool = false
    @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5
    @AppStorage("general.syncColumns") public var syncColumns: Bool = false

    var body: some View {
        Form {
            Group {
                Text("Visual appearance")
                Toggle("Tiger stripe table rows", isOn: $tigerStriped)
                Toggle("Auto-correct text in text boxes", isOn: $enableAutoCorrection)
            }

            Group {
                Toggle("Enable experimental features (EXERCISE CAUTION)", isOn: $showExperimentalFeatures)

                if showExperimentalFeatures {
                    Toggle("Auto-fix records with bad jobs", isOn: $autoFixJobs)
                }
            }

            Group {
                Text("Export options")
                Toggle("Synchronize display and export columns", isOn: $syncColumns)
                    .help("Both table display and data exports will use the same columns set under 'Today > Display columns'")
            }
        }
        .padding(20)
    }
}

struct GeneralSettingsPreview: PreviewProvider {
    static var previews: some View {
        GeneralSettings()
    }
}
