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
            Activity(name: "Activity Calendar", page: .activityCalendar, type: .visualize, icon: "calendar"),
            Activity(name: "Flashcards", page: .activityFlashcards, type: .activity, icon: "person.text.rectangle"),
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    UniversalHeader.Widget(
                        type: .BruceWillis,
                        title: "Explore"
                    )
                    UI.EntityStatistics()
                }
                UI.ExploreLinks()
                UI.Navigator()
                // @TODO: tmp disabled
                //            Widgets()
                Spacer()
            }
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
