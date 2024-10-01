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
    @AppStorage("notes.columns") private var numColumns: Int = 3
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .terms
    private var columns: [GridItem] {
        return Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }
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
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(self.terms, id: \.objectID) { term in
                                TermBlock(term: term)
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
            self.terms = CoreDataTaxonomyTermDefinitions(moc: self.state.moc).definitions(for: job)
        } else {
            self.terms = []
        }
    }
}

struct TermBlock: View {
    public let term: TaxonomyTermDefinitions
    @State private var highlighted: Bool = false

    var body: some View {
        Button {

        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Color.white
                        .shadow(color: .black.opacity(1), radius: 3)
                        .opacity(highlighted ? 0.2 : 0.1)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(self.term.definition?.capitalized ?? "_TERM_NAME")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding([.leading, .trailing, .top])
//                        Text(noteBody())
//                            .padding([.leading, .trailing, .bottom])

                        Spacer()
//                        jobAndProject
                    }
                }
            }
        }
        .frame(height: 150)
        .useDefaultHover({ inside in highlighted = inside})
        .buttonStyle(.plain)
    }
}
