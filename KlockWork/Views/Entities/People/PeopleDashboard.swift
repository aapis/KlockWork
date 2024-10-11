//
//  PeopleDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-03.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct PeopleDashboard: View {
    typealias Widget = WidgetLibrary.UI.Buttons
    @EnvironmentObject public var state: Navigation
    @AppStorage("general.columns") private var numColumns: Int = 3
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .people
    private var columns: [GridItem] {
        return Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }
    @State private var searchText: String = ""
    @State private var people: [Person] = []

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                UniversalHeader.Widget(
                    type: self.eType,
                    title: self.eType.label
                )

                if self.people.count > 0 {
                    SearchBar(
                        text: $searchText,
                        disabled: false,
                        placeholder: self.people.count > 1 ? "Filter \(self.people.count) people" : "Filter by name"
                    )

                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(self.filter(self.people), id: \Person.objectID) { person in
                                PersonBlock(person: person)
                            }
                        }
                    }
                } else {
                    FancyHelpText(
                        text: "Find contacts. Choose a company from the sidebar to get started.",
                        page: self.page
                    )
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onChange(of: self.state.session.job) { self.actionOnAppear() }
        .onChange(of: self.state.session.person) { self.actionOnAppear() }
        .onChange(of: self.state.session.company) { self.actionOnAppear() }
        .onAppear(perform: self.actionOnAppear)
    }
}

extension PeopleDashboard {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let person = self.state.session.person {
            if let company = person.company {
                self.people = CoreDataPerson(moc: self.state.moc).byCompany(company)
            }
        } else if let job = self.state.session.job {
            if let company = job.project?.company {
                self.people = CoreDataPerson(moc: self.state.moc).byCompany(company)
            }
        } else if let company = self.state.session.company {
            self.people = CoreDataPerson(moc: self.state.moc).byCompany(company)
        } else {
            self.people = []
        }
    }

    /// Filter terms by input text
    /// - Parameter terms: Person
    /// - Returns: [Person]
    private func filter(_ terms: [Person]) -> [Person] {
        return SearchHelper(bucket: terms).findInPeople($searchText)
    }

    /// Fires when a term block is clicked/tapped
    /// - Returns: Void
    private func actionOnTap() -> Void {

    }
}

struct PersonBlock: View {
    @EnvironmentObject public var state: Navigation
    public let person: Person
    @State private var highlighted: Bool = false

    var body: some View {
        Button {
            self.state.session.person = self.person
            self.state.to(.peopleDetail)
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Color.white
                        .shadow(color: .black.opacity(1), radius: 3)
                        .opacity(highlighted ? 0.2 : 0.1)

                    VStack(alignment: .leading, spacing: 0) {
                        Text(person.name ?? "_CONTACT_NAME")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding([.leading, .trailing, .top])
                        Text(person.title ?? "_CONTACT_TITLE")
                            .foregroundStyle(.white.opacity(0.55))
                            .padding([.leading, .trailing, .bottom])
                        Spacer()
                        ResourcePath(company: self.person.company)
                    }
                }
            }
        }
        .frame(height: 150)
        .useDefaultHover({ inside in highlighted = inside})
        .buttonStyle(.plain)
    }

    struct ResourcePath: View {
        public var company: Company?
        @EnvironmentObject public var state: Navigation

        var body: some View {
            if let company = self.company {
                HStack(alignment: .center, spacing: 8) {
                    Text(company.name ?? "_COMPANY_NAME")
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(7)
                .background(company.backgroundColor)
                .foregroundStyle(company.backgroundColor.isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                .frame(height: 30)
            }
        }
    }
}
