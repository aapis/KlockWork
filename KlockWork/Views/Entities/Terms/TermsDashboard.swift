//
//  TermDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-08-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import KWCore

struct TermsDashboard: View {
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
                                TermBlock(definition: def)
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

struct TermBlock: View {
    typealias UI = WidgetLibrary.UI
    @EnvironmentObject public var state: Navigation
    public let definition: TaxonomyTermDefinitions
    @State private var highlighted: Bool = false

    var body: some View {
        Button {
            self.actionOnTap()
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Color.white
                        .shadow(color: .black.opacity(1), radius: 3)
                        .opacity(highlighted ? 0.2 : 0.1)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(self.definition.term?.name ?? "_TERM_NAME")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding([.leading, .trailing, .top])
                        Text(self.definitionBody())
                            .foregroundStyle(.white.opacity(0.55))
                            .padding([.leading, .trailing, .bottom])
                        Spacer()
                        UI.ResourcePath(
                            company: self.state.session.job?.project?.company,
                            project: self.state.session.job?.project,
                            job: self.state.session.job
                        )
                    }
                }
            }
        }
        .frame(height: 150)
        .clipShape(.rect(cornerRadius: 5))
        .useDefaultHover({ inside in highlighted = inside})
        .buttonStyle(.plain)
    }
}

extension TermBlock {
    /// Trucate term answer
    /// - Returns: String
    private func definitionBody() -> String {
        if let body = self.definition.definition {
            if body.count > 100 {
                let i = body.index(body.startIndex, offsetBy: 100)
                let description = String(body[...i]).trimmingCharacters(in: .whitespacesAndNewlines)

                return description + "..."
            }
        }

        return "No preview available"
    }
    
    /// Fires when a term block is clicked/tapped
    /// - Returns: Void
    private func actionOnTap() -> Void {
        self.state.setView(AnyView(DefinitionDetail(definition: self.definition)))
        self.state.setSidebar(AnyView(DefinitionSidebar()))
        self.state.setId()
    }
}
