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
    typealias UI = WidgetLibrary.UI
    @EnvironmentObject public var state: Navigation
    private var activities: [Activity] {
        [
            Activity(name: "Activity Calendar", page: .dashboard, type: .visualize, icon: "calendar"),
            Activity(name: "Flashcards", page: .dashboard, type: .activity, icon: "person.text.rectangle"),
        ]
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                UniversalHeader.Widget(
                    type: .BruceWillis,
                    title: "Explore"
                )
                UI.EntityStatistics()
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    ForEach(ExploreActivityType.allCases, id: \.hashValue) { type in
                        VStack(alignment: .leading, spacing: 5) {
                            UI.ListLinkTitle(type: type)

                            ForEach(self.activities.filter({$0.type == type}), id: \.id) { activity in
                                UI.ListLinkItem(activity: activity)
                            }
                            Spacer()
                        }
                        .frame(height: 150)
                        .padding()
                        .background(Theme.textBackground)
//                        .background(self.state.session.job?.backgroundColor.opacity(0.2) ?? Theme.textBackground)
                        .clipShape(.rect(cornerRadius: 5))
                    }
                }
            }
            // @TODO: tmp disabled
//            Widgets()
            Spacer()
        }
        .padding()
        .background(Theme.toolbarColour)
    }
}

struct Activity: Identifiable {
    var id: UUID = UUID()
    var name: String
    var page: Page
    var type: ExploreActivityType
    var icon: String?
    var iconAsImage: Image?
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
