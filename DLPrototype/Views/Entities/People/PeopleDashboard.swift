//
//  PeopleDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-03.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct PeopleDashboard: View {
    @EnvironmentObject public var state: Navigation
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .people
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .center, spacing: 0) {
                    Title(text: eType.label, imageAsImage: eType.icon)
                    Spacer()
                    FancyButtonv2(text: "New person", action: {}, icon: "plus", showLabel: false)
                }
                FancyDivider()
                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onChange(of: self.state.session.job) { self.actionOnAppear() }
        .onAppear(perform: self.actionOnAppear)
    }
}

extension PeopleDashboard {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {

    }

    /// Filter terms by input text
    /// - Parameter terms: TaxonomyTerm
    /// - Returns: [TaxonomyTermDefinitions]
    private func filter(_ terms: [TaxonomyTermDefinitions]) -> [TaxonomyTermDefinitions] {
        return SearchHelper(bucket: terms).findInDefinitions($searchText)
    }

    /// Fires when a term block is clicked/tapped
    /// - Returns: Void
    private func actionOnTap() -> Void {
        self.state.setView(AnyView(DefinitionDetail()))
        self.state.setId()
    }
}
