//
//  ProjectsDashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct ProjectsDashboardSidebar: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5) {
                ProjectsWidget()
            }
            Spacer()
        }
        .padding()
    }
}

