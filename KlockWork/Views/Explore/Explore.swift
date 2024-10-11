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
    private var activities: [Activity] {
        [
            Activity(name: "Activity calendar", view: AnyView(Dashboard())),
            Activity(name: "Flashcards", view: AnyView(Dashboard())),
        ]
    }

    var body: some View {
        VStack(alignment: .leading) {
            UniversalHeader.StandaloneWidget(
                type: .BruceWillis,
                title: "Explore"
            )

            ForEach(self.activities, id: \.id) { activity in
                Button {

                } label: {
                    Text(activity.name)
                }
                .buttonStyle(.plain)
            }

            Widgets()
            Spacer()
        }
        .padding()
        .background(Theme.toolbarColour)
    }
}

struct Activity: Identifiable {
    var id: UUID = UUID()
    var name: String
    var view: AnyView
}
