//
//  TermDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-08-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct TermsDashboard: View {
    typealias Widget = WidgetLibrary.UI.Buttons
    @EnvironmentObject public var state: Navigation
    @AppStorage("general.columns") private var numColumns: Int = 3
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .terms
    private var columns: [GridItem] {
        return Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }
    @State public var job: Job?
    @State private var terms: [TaxonomyTerm] = []
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                UniversalHeader.Widget(
                    type: self.eType,
                    title: self.eType.label
                )

                if self.terms.count > 0 {
                    UI.BoundSearchBar(
                        text: $searchText,
                        disabled: false,
                        placeholder: self.terms.count > 1 ? "Filter \(self.terms.count) terms" : "Filter terms"
                    )
                    .clipShape(.rect(bottomLeadingRadius: 5, bottomTrailingRadius: 5))

                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(self.filter(self.terms), id: \TaxonomyTerm.objectID) { term in
                                UI.Blocks.Term(term: term)
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

extension TermsDashboard {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.job = self.state.session.job

        if let job = self.job {
            let definitions = CoreDataTaxonomyTermDefinitions(moc: self.state.moc).definitions(for: job)
            let grouped = Dictionary(grouping: definitions, by: {$0.term!})
            var tSet: Set<TaxonomyTerm> = []
            for item in grouped {
                tSet.insert(item.key)
            }

            self.terms = Array(tSet).sorted(by: {$0.name ?? "" < $1.name ?? ""})
        } else {
            self.terms = []
        }
    }

    /// Filter terms by input text
    /// - Parameter terms: TaxonomyTerm
    /// - Returns: [TaxonomyTermDefinitions]
    private func filter(_ terms: [TaxonomyTerm]) -> [TaxonomyTerm] {
        return SearchHelper(bucket: terms).findInTerms($searchText)
    }
}
