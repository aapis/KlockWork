//
//  NoteDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-08.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct NoteDashboard: View {
    typealias Widget = WidgetLibrary.UI.Buttons
    typealias UI = WidgetLibrary.UI
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
    @AppStorage("general.columns") private var numColumns: Int = 3
    @AppStorage("notedashboard.listVisible") private var listVisible: Bool = true
    @AppStorage("widget.jobs.showPublished") private var showPublished: Bool = true
    @State private var searchText: String = ""
    @State private var selected: Int = 0
    @State private var showAllNotes: Bool = false
    @State private var notes: [Note] = []
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .notes
    private var columns: [GridItem] {
        return Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 1) {
                UniversalHeader.Widget(
                    type: self.eType,
                    title: self.eType.label
                )

                CompanyNotebooks()

                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        Text("Recently updated").font(.title2)
                        Spacer()
                        FancySimpleButton(
                            text: listVisible ? "Close" : "Open",
                            action: {listVisible.toggle()},
                            icon: listVisible ? "minus.square.fill" : "plus.square.fill",
                            showLabel: false,
                            showIcon: true,
                            size: .tiny,
                            type: .clear
                        )
                    }

                    HStack {
                        Text("Notes are sorted from most to least recently updated.")
                            .font(.caption)
                        Spacer()
                    }
                }
                .padding(5)
                .background(.white.opacity(0.2))
                .foregroundStyle(.white)
                
                if listVisible && self.notes.count > 0 {
                    UI.BoundSearchBar(
                        text: $searchText,
                        disabled: false,
                        placeholder: notes.count > 1 ? "Filter \(self.notes.count) notes" : "Filter 1 note"
                    )
                    FancyDivider(height: 20)

                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: self.columns, alignment: .leading) {
                            ForEach(self.filter(self.notes), id: \.objectID) { note in
                                NoteBlock(note: note)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.nav.session.job) { self.actionOnAppear() }
        .onChange(of: self.showPublished) { self.actionOnAppear() }
    }
}

extension NoteDashboard {
    /// Perform a search of note content and meta data
    /// - Parameter notes: [Note]
    /// - Returns: [Note
    private func filter(_ notes: [Note]) -> [Note] {
        return SearchHelper(bucket: notes).findInNotes($searchText)
    }
    
    /// Onload handler. Find based on appropriate filter entity
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.notes = CoreDataNotes(moc: self.nav.moc).alive()

        if let stored = self.nav.session.job {
            self.notes = CoreDataNotes(moc: self.nav.moc).find(by: stored, allowKilled: self.showPublished)
        } else if let stored = self.nav.session.project {
            self.notes = CoreDataNotes(moc: self.nav.moc).find(by: stored, allowKilled: self.showPublished)
        }
    }
}

extension NoteDashboard {
    struct CompanyNotebooks: View {
        @AppStorage("notedashboard.explorerVisible") private var explorerVisible: Bool = true

        @FetchRequest public var companies: FetchedResults<Company>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        Text("Project Notebooks").font(.title2)
                        Spacer()
                        FancySimpleButton(
                            text: explorerVisible ? "Close" : "Open",
                            action: {explorerVisible.toggle()},
                            icon: explorerVisible ? "minus.square.fill" : "plus.square.fill",
                            showLabel: false,
                            showIcon: true,
                            size: .tiny,
                            type: .clear
                        )
                    }

                    HStack {
                        Text("Find notes by project.")
                            .font(.caption)
                        Spacer()
                    }
                }
                .padding(5)
                .background(.white.opacity(0.2))
                .foregroundStyle(.white)

                if explorerVisible {
                    ThreePanelGroup(orientation: .horizontal, data: companies, lastColumnType: .notes)
                }
            }
        }

        init() {
            _companies = CoreDataCompanies.fetch()
        }
    }
}
