//
//  TermDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-08-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct TermsDashboard: View {
    @EnvironmentObject public var state: Navigation
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .terms
    @State public var job: Job?
    @State private var terms: [TaxonomyTermDefinitions] = []

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 10) {
                    eType.icon
                    Text(eType.label)
                    Spacer()
                    FancyButtonv2(text: "Create term", action: {}, icon: "plus", showLabel: false)
                }
                .font(.title2)

                if self.terms.count > 0 {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(self.terms, id: \.objectID) { term in
                                Text(term.definition ?? "_TERM_NAME")
                            }

                        }
                    }
                } else {
                    Text("No Terms")
                }

                Spacer()
            }
            .padding()
        }
        .background(self.page.primaryColour)
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
            self.terms = CoreDataTaxonomyTermDefinitions(moc: self.state.moc).definitions(for: job)
        } else {
            self.terms = []
        }
    }
}
