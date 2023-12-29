//
//  DefaultPlanningSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-24.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct DefaultPlanningSidebar: View {
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5) {
                AllJobsPickerWidget(location: .sidebar)
            }
            Spacer()
        }
        .padding()
    }
}
