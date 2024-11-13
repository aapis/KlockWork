//
//  Explore.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-10.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct Explore: View {
    @EnvironmentObject public var state: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 0) {
                UniversalHeader.Widget(
                    type: .BruceWillis,
                    title: "Explore"
                )
                UI.EntityStatistics()
            }
            UI.ExploreLinks()
            UI.Navigator()
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

struct Activity: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var help: String = ""
    var page: Page
    var type: ExploreActivityType
    var icon: String?
    var iconAsImage: Image?
    var job: Job?
    var source: NSManagedObject?
    var url: URL?
}

enum ExploreActivityType: CaseIterable {
    case visualize, activity

    var title: String {
        switch self {
        case .visualize: "Visualize your Data"
        case .activity: "Activities"
        }
    }
}
