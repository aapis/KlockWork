//
//  DefinitionDashboard.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-11-12.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct DefinitionDashboard: View {
    typealias Widget = WidgetLibrary.UI.Buttons
    typealias UI = WidgetLibrary.UI
    @EnvironmentObject public var state: Navigation
    @AppStorage("general.columns") private var numColumns: Int = 3
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .terms
    private var columns: [GridItem] {
        return Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }
    @State public var job: Job?
    @State private var definitions: [TaxonomyTermDefinitions] = []
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                UniversalHeader.Widget(
                    type: self.eType,
                    title: self.eType.label
                )

                if self.definitions.count > 0 {
                    UI.BoundSearchBar(
                        text: $searchText,
                        disabled: false,
                        placeholder: self.definitions.count > 1 ? "Filter \(self.definitions.count) terms & definitions" : "Filter terms & definitions"
                    )

                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(self.filter(self.definitions), id: \TaxonomyTermDefinitions.objectID) { def in
                                UI.Blocks.DefinitionAlternative(definition: def)
                            }
                        }
                    }
                    .padding(.top)
                } else {
                    FancyHelpText(
                        text: "No terms found for the selected job. Choose a job from the sidebar to get started.",
                        page: self.page
                    )
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onChange(of: self.state.session.job) { self.actionOnAppear() }
        .onAppear(perform: self.actionOnAppear)
    }
}

extension DefinitionDashboard {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.job = self.state.session.job

        if let job = self.job {
            self.definitions = CoreDataTaxonomyTermDefinitions(moc: self.state.moc).definitions(for: job)
        } else {
            self.definitions = []
        }
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

