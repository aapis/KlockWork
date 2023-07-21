//
//  NoteDashboardSettings.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-21.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct NoteDashboardSettings: View {
    @AppStorage("notes.columns") private var columns: Int = 3

    var body: some View {
        Form {
            Group {
                Picker("Number of columns to display", selection: $columns) {
                    Text("2").tag(2)
                    Text("3").tag(3)
                    Text("4").tag(4)
                    Text("5").tag(5)
                }

            }
        }
        .padding(20)
    }
}

struct NoteDashboardSettingsPreview: PreviewProvider {
    static var previews: some View {
        NoteDashboard()
    }
}
