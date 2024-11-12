//
//  Dashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct Dashboard: View {
    @EnvironmentObject public var state: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FindDashboard(location: .content)
            Spacer()
        }
        .padding()
        .background(
            ZStack {
                self.state.session.appPage.primaryColour
                Theme.base.opacity(0.6)
            }
        )
    }
}
