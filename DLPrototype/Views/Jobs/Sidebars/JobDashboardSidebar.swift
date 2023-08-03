//
//  JobDashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobDashboardSidebar: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ScrollView(showsIndicators: false) {
                RecentJobsWidget()
            }

            Spacer()
        }
        .padding()
    }
}
