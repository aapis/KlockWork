//
//  Explore.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-11-05.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension WidgetLibrary.UI {
    struct Explore {
        struct Visualization {
            // MARK: Explore.Visualization.Timeline
            struct Timeline: View {
                @EnvironmentObject public var state: Navigation
                @AppStorage("settings.accessibility.showUIHints") private var showUIHints: Bool = true
                private var threeCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 3) }
                private var twoCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 2) }

                var body: some View {
                    VStack(alignment: .leading, spacing: 0) {
                        UI.SearchTypeFilter()
                            .background(self.state.session.appPage.primaryColour)
                            .clipShape(.rect(topLeadingRadius: 5, topTrailingRadius: 5))
                            .clipShape(.rect(bottomLeadingRadius: self.showUIHints ? 0 : 5, bottomTrailingRadius: self.showUIHints ? 0 : 5))
                        FancyHelpText(
                            text: "Browse through historical records for \(DateHelper.todayShort(self.state.session.date, format: "MMMM dd"))",
                            page: self.state.session.appPage
                        )
                        FancyDivider()
                        // @TODO: add up to 3 widgets here (plan, tasks, score, ???)
                        //                    LazyVGrid(columns: self.threeCol, alignment: .center) {
                        //                        VStack {
                        //                            UI.ListLinkTitle(text: "Tasks")
                        //                            Forecast(
                        //                                date: DateHelper.startOfDay(self.state.session.timeline.date),
                        //                                type: .button,
                        //                                page: self.state.session.appPage
                        //                            )
                        //                        }
                        //                        VStack {
                        //                            UI.ListLinkTitle(text: "Score")
                        //                            GlobalSidebarWidgets.ScoreButton()
                        //                        }
                        //                    }
                        //                    FancyDivider()
                        VStack(spacing: 0) {
                            LazyVGrid(columns: self.twoCol, alignment: .leading) {
                                GridRow {
                                    UI.LinkListForDate()
                                    UI.EntityInteractionsForDate()
                                }
                            }
                        }
                        FancyDivider()
                        UI.ActivityFeed()
                    }
                    .padding()
                    .background(Theme.toolbarColour)
                }
            }
        }

        // MARK: Activity
        struct Activity {
            // MARK: FlashcardActivity
            struct FlashcardActivity: View {
                @EnvironmentObject private var state: Navigation
                private var page: PageConfiguration.AppPage = .explore
                @State private var isJobSelectorPresented: Bool = false
                @State private var job: Job? // @TODO: rewrite to use self.state.session.job

                var body: some View {
                    VStack(alignment: .leading, spacing: 0) {
                        FlashcardDeck(job: $job)
                    }
                    .onAppear(perform: {
                        if self.state.session.job != nil {
                            self.job = self.state.session.job
                            self.isJobSelectorPresented = false
                        } else {
                            self.isJobSelectorPresented = true
                        }
                    })
                    .onChange(of: self.state.session.job) { self.job = self.state.session.job }
                    .background(self.page.primaryColour)
                    .navigationTitle(job != nil ? self.job!.title ?? self.job!.jid.string: "Activity: Flashcard")
            #if os(iOS)
                    .toolbarBackground(job != nil ? self.job!.backgroundColor : Theme.textBackground.opacity(0.7), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
            #endif
                }

                struct FlashcardDeck: View {
                    @EnvironmentObject private var state: Navigation
                    @Binding public var job: Job?
                    @State private var terms: Array<TaxonomyTerm> = []
                    @State private var current: TaxonomyTerm? = nil
                    @State private var isAnswerCardShowing: Bool = false
                    @State private var clue: String = ""
                    @State private var viewed: Set<TaxonomyTerm> = []
                    @State private var definitions: [TaxonomyTermDefinitions] = []

                    var body: some View {
                        VStack(alignment: .center, spacing: 0) {
                            Card(
                                isAnswerCardShowing: $isAnswerCardShowing,
                                definitions: $definitions,
                                current: $current,
                                job: $job
                            )
                            Actions(
                                isAnswerCardShowing: $isAnswerCardShowing,
                                definitions: $definitions,
                                current: $current,
                                terms: $terms,
                                viewed: $viewed
                            )
                        }
                        .onAppear(perform: self.actionOnAppear)
                        .onChange(of: job) {
                            self.actionOnAppear()
                        }
                    }

                    struct Actions: View {
                        @EnvironmentObject private var state: Navigation
                        @Binding public var isAnswerCardShowing: Bool
                        @Binding public var definitions: [TaxonomyTermDefinitions]
                        @Binding public var current: TaxonomyTerm?
                        @Binding public var terms: [TaxonomyTerm]
                        @Binding public var viewed: Set<TaxonomyTerm>

                        var body: some View {
                            ZStack(alignment: .topLeading) {
                                LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                    .frame(height: 50)
                                    .opacity(0.06)

                                Buttons
                            }
                        }

                        var Buttons: some View {
                            HStack(alignment: .center) {
                                Button {
                                    self.isAnswerCardShowing.toggle()
                                } label: {
                                    ZStack(alignment: .center) {
                                        LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                                        Image(systemName: "rectangle.landscape.rotate")
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding()
                                .mask(Circle().frame(width: 50, height: 50))

                                Button {
                                    self.isAnswerCardShowing = false
                                } label: {
                                    ZStack(alignment: .center) {
                                        LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                                        Image(systemName: "hand.thumbsup.fill")
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding()
                                .mask(Circle().frame(width: 50, height: 50))

                                Button {
                                    self.isAnswerCardShowing = false
                                } label: {
                                    ZStack(alignment: .center) {
                                        LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                                        Image(systemName: "hand.thumbsdown.fill")
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding()
                                .mask(Circle().frame(width: 50, height: 50))

                                Button {
                                    self.isAnswerCardShowing = false

                                    if let next = self.terms.randomElement() {
                                        if next != current {
                                            // Pick another random element if we've seen the next item already
                                            if !self.viewed.contains(next) {
                                                current = next
                                            } else {
                                                current = self.terms.randomElement()
                                            }
                                        }
                                    }

                                    if self.current != nil {
                                        viewed.insert(self.current!)
                                    }
                                } label: {
                                    ZStack(alignment: .center) {
                                        LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding()
                                .mask(Circle().frame(width: 50, height: 50))
                            }
                            .frame(height: 90)
                            .border(width: 1, edges: [.top], color: self.state.theme.tint)
                        }
                    }

                    struct Card: View {
                        @Binding public var isAnswerCardShowing: Bool
                        @Binding public var definitions: [TaxonomyTermDefinitions] // @TODO: convert this to dict grouped by job
                        @Binding public var current: TaxonomyTerm?
                        @Binding public var job: Job?
                        @State private var clue: String = ""

                        var body: some View {
                            VStack(alignment: .leading, spacing: 0) {
                                if self.isAnswerCardShowing {
                                    // Definitions
                                    HStack(alignment: .center, spacing: 0) {
                                        Text("\(self.definitions.count) Jobs define \"\(self.clue)\"")
                                            .textCase(.uppercase)
                                            .font(.caption)
                                            .padding(5)
                                        Spacer()
                                    }
                                    .background(self.job?.backgroundColor ?? Theme.rowColour)

                                    VStack(alignment: .leading, spacing: 0) {
                                        ScrollView {
                                            VStack(alignment: .leading, spacing: 1) {
                                                ForEach(Array(definitions.enumerated()), id: \.element) { idx, term in
                                                    VStack(alignment: .leading, spacing: 0) {
                                                        HStack(alignment: .top) {
                                                            Text((term.job?.title ?? term.job?.jid.string) ?? "_JOB_NAME")
                                                                .multilineTextAlignment(.leading)
                                                                .padding(14)
                                                                .foregroundStyle((term.job?.backgroundColor ?? Theme.rowColour).isBright() ? .white.opacity(0.75) : .gray)
                                                            Spacer()
                                                        }


                                                        ZStack(alignment: .topLeading) {
                                                            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                                                .frame(height: 50)
                                                                .opacity(0.1)

                                                            NavigationLink {
                                                                DefinitionDetail(definition: term)
                                                            } label: {
                                                                HStack(alignment: .center) {
                                                                    Text(term.definition ?? "Definition not found")
                                                                        .multilineTextAlignment(.leading)
                                                                    Spacer()
                                                                    Image(systemName: "chevron.right")
                                                                }
                                                                .padding(14)
                                                            }
                                                            .buttonStyle(.plain)
                                                        }
                                                    }
                                                    .background(term.job?.backgroundColor)
                                                    .foregroundStyle((term.job?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    // Answer
                                    if self.current != nil {
                                        VStack(alignment: .leading, spacing: 0) {
                                            Spacer()
                                            VStack(alignment: .center) {
                                                Text("Clue")
                                                    .foregroundStyle((self.job?.backgroundColor ?? Theme.rowColour).isBright() ? .white.opacity(0.75) : .gray)
                                                Text(clue)
                                                    .font(.title2)
                                                    .bold()
                                                    .multilineTextAlignment(.center)
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .onChange(of: current) {
                                if self.current != nil {
                                    self.clue = current?.name ?? "Clue"

                                    if let defs = self.current!.definitions {
                                        if let ttds = defs.allObjects as? [TaxonomyTermDefinitions] {
                                            self.definitions = ttds
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // MARK: FlashcardActivity.Flashcard
                struct Flashcard {
                    var term: TaxonomyTerm
                }
            }
        }
    }
}

extension WidgetLibrary.UI.Explore.Activity.FlashcardActivity.FlashcardDeck {
    /// Onload/onChangeJob handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.isAnswerCardShowing = false
        self.terms = []
        self.definitions = []
        self.current = nil
        self.clue = ""

        if self.job != nil {
            if let termsForJob = CoreDataTaxonomyTerms(moc: self.state.moc).byJob(self.job!) {
                self.terms = termsForJob
            }
        }

        if !self.terms.isEmpty {
            self.current = self.terms.randomElement()
            self.clue = self.current?.name ?? "_TERM_NAME"
            self.viewed.insert(self.current!)
//            self.definitions = []

            if let defs = self.current!.definitions {
                if let ttds = defs.allObjects as? [TaxonomyTermDefinitions] {
                    self.definitions = ttds
                }
            }
        }
    }
}
