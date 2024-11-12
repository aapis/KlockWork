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
            struct Timeline {
                enum TimelineTab: CaseIterable {
                    case day, week, month, year, entity, custom

                    var icon: String {
                        switch self {
                        case .day: "d.square.fill"
                        case .week: "w.square.fill"
                        case .month: "m.square.fill"
                        case .year: "y.square.fill"
                        case .entity: "e.square.fill"
                        case .custom: "c.square.fill"
                        }
                    }

                    var id: Int {
                        switch self {
                        case .day: 0
                        case .week: 1
                        case .month: 2
                        case .year: 3
                        case .entity: 4
                        case .custom: 5
                        }
                    }

                    var help: String {
                        switch self {
                        case .day: "Show 1 day"
                        case .week: "Show 1 week"
                        case .month: "Show 1 month"
                        case .year: "Show 1 year"
                        case .entity: "Show timeline(s) for the selected entities"
                        case .custom: "Custom range"
                        }
                    }

                    var title: String {
                        switch self {
                        case .day: "Day"
                        case .week: "Week"
                        case .month: "Month"
                        case .year: "Year"
                        case .entity: "Entity"
                        case .custom: "Custom Range"
                        }
                    }

                    var view: AnyView {
                        switch self {
                        case .day: AnyView(ByDay())
                        case .week: AnyView(ByWeek())
                        case .month: AnyView(ByMonth())
                        case .year: AnyView(ByYear())
                        case .entity: AnyView(ByEntity())
                        case .custom: AnyView(ByCustomRange())
                        }
                    }

                    var button: ToolbarButton {
                        ToolbarButton(
                            id: self.id,
                            helpText: self.help,
                            icon: self.icon,
                            labelText: self.title,
                            contents: self.view
                        )
                    }
                }

                // MARK: Timeline.Widget
                struct Widget: View {
                    @EnvironmentObject public var nav: Navigation
                    private var tabs: [ToolbarButton] = []

                    var body: some View {
                        VStack {
                            FancyGenericToolbar(
                                buttons: self.tabs,
                                standalone: true,
                                location: .content,
                                mode: .compact,
                                page: .explore,
                                scrollable: false
                            )
                        }
                        .padding()
                        .background(Theme.toolbarColour)
                    }

                    init() {
                        TimelineTab.allCases.forEach { tab in
                            self.tabs.append(tab.button)
                        }
                    }
                }

                // MARK: Timeline.ByDay
                struct ByDay: View {
                    @EnvironmentObject public var state: Navigation
                    @AppStorage("settings.accessibility.showUIHints") private var showUIHints: Bool = true
                    private var threeCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 3) }
                    private var twoCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 2) }

                    var body: some View {
                        VStack(alignment: .leading, spacing: 0) {
                            UI.SearchTypeFilter()
                                .background(self.state.session.appPage.primaryColour)
                                .clipShape(.rect(topTrailingRadius: 5))
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
                            LazyVGrid(columns: self.twoCol, alignment: .leading, spacing: 0) {
                                GridRow {
                                    UI.SuggestedStack(
                                        period: .day,
                                        format: "MMMM dd"
                                    )
                                    UI.InteractionsInRange(
                                        period: .day,
                                        format: "MMMM dd"
                                    )
                                }
                            }
                            FancyDivider()
                            UI.ActivityFeed()
                        }
                    }
                }

                // MARK: Timeline.ByWeek
                struct ByWeek: View {
                    @EnvironmentObject public var state: Navigation
                    @AppStorage("settings.accessibility.showUIHints") private var showUIHints: Bool = true
                    private var twoCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 2) }

                    var body: some View {
                        VStack(alignment: .leading, spacing: 0) {
                            UI.SearchTypeFilter()
                                .background(self.state.session.appPage.primaryColour)
                                .clipShape(.rect(topTrailingRadius: 5))
                                .clipShape(.rect(bottomLeadingRadius: self.showUIHints ? 0 : 5, bottomTrailingRadius: self.showUIHints ? 0 : 5))
                            FancyHelpText(
                                text: "Browse through historical records for week \(DateHelper.todayShort(self.state.session.date, format: "w"))",
                                page: self.state.session.appPage
                            )
                            FancyDivider()
                            UI.EntityCalendar.WeekWidget(
                                start: self.state.session.date.startOfWeek
                            )
                            FancyDivider()
                            UI.ActivityFeed()
                            FancyDivider()
                            Spacer()
                            LazyVGrid(columns: self.twoCol, alignment: .leading) {
                                GridRow {
                                    UI.SuggestedStack(
                                        period: .week,
                                        format: "w"
                                    )
                                    UI.InteractionsInRange(
                                        period: .week,
                                        format: "w"
                                    )
                                }
                            }
                        }
                    }
                }

                // MARK: Timeline.ByMonth
                struct ByMonth: View {
                    @EnvironmentObject public var state: Navigation
                    @AppStorage("settings.accessibility.showUIHints") private var showUIHints: Bool = true
                    private var twoCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 2) }

                    var body: some View {
                        VStack(alignment: .leading, spacing: 0) {
                            UI.SearchTypeFilter()
                                .background(self.state.session.appPage.primaryColour)
                                .clipShape(.rect(topTrailingRadius: 5))
                                .clipShape(.rect(bottomLeadingRadius: self.showUIHints ? 0 : 5, bottomTrailingRadius: self.showUIHints ? 0 : 5))
                            FancyHelpText(
                                text: "Browse through historical records for \(DateHelper.todayShort(self.state.session.date, format: "MMMM"))",
                                page: self.state.session.appPage
                            )
                            FancyDivider()
                            LazyVGrid(columns: self.twoCol, alignment: .leading) {
                                GridRow {
                                    UI.SuggestedLinksInRange(
                                        period: .month,
                                        start: self.state.session.date.startOfMonth,
                                        end: self.state.session.date.endOfMonth,
                                        format: "MMMM"
                                    )
                                    UI.SavedSearchTermsInRange(
                                        period: .month,
                                        start: self.state.session.date.startOfMonth,
                                        end: self.state.session.date.endOfMonth,
                                        format: "MMMM"
                                    )
                                }
                            }
                            FancyDivider()
                            UI.InteractionsInRange(
                                period: .month,
                                start: self.state.session.date.startOfMonth,
                                end: self.state.session.date.endOfMonth,
                                format: "MMMM"
                            )
                        }
                    }
                }

                // MARK: Timeline.ByYear
                struct ByYear: View {
                    @EnvironmentObject public var state: Navigation
                    @AppStorage("settings.accessibility.showUIHints") private var showUIHints: Bool = true
                    private var twoCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 2) }

                    var body: some View {
                        VStack(alignment: .leading, spacing: 0) {
                            UI.SearchTypeFilter()
                                .background(self.state.session.appPage.primaryColour)
                                .clipShape(.rect(topTrailingRadius: 5))
                                .clipShape(.rect(bottomLeadingRadius: self.showUIHints ? 0 : 5, bottomTrailingRadius: self.showUIHints ? 0 : 5))
                            FancyHelpText(
                                text: "Browse through historical records for \(DateHelper.todayShort(self.state.session.date, format: "yyyy"))",
                                page: self.state.session.appPage
                            )
                            FancyDivider()
                            LazyVGrid(columns: self.twoCol, alignment: .leading) {
                                GridRow {
                                    UI.SuggestedLinksInRange(
                                        period: .year,
                                        start: self.state.session.date.startOfYear,
                                        end: self.state.session.date.endOfYear,
                                        format: "yyyy"
                                    )
                                    UI.SavedSearchTermsInRange(
                                        period: .year,
                                        start: self.state.session.date.startOfYear,
                                        end: self.state.session.date.endOfYear,
                                        format: "yyyy"
                                    )
                                }
                            }
                            FancyDivider()
                            UI.InteractionsInRange(
                                period: .year,
                                start: self.state.session.date.startOfYear,
                                end: self.state.session.date.endOfYear,
                                format: "yyyy"
                            )
                        }
                    }
                }

                // MARK: Timeline.ByCustomRange
                struct ByCustomRange: View {
                    @EnvironmentObject public var state: Navigation
                    @AppStorage("settings.accessibility.showUIHints") private var showUIHints: Bool = true
                    @State private var start: Date = Date()
                    @State private var end: Date = Date() + 86400
                    private var twoCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 2) }

                    var body: some View {
                        VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading) {
                                UI.SearchTypeFilter()
                                HStack {
                                    DatePicker("Start", selection: $start).labelsHidden()
                                    Text("To")
                                    DatePicker("End", selection: $end).labelsHidden()
                                }
                                .padding(8)
                            }
                            .background(self.state.session.appPage.primaryColour)
                            .clipShape(.rect(topTrailingRadius: 5))
                            .clipShape(.rect(bottomLeadingRadius: self.showUIHints ? 0 : 5, bottomTrailingRadius: self.showUIHints ? 0 : 5))
                            FancyHelpText(
                                text: "Browse through historical records period \(DateHelper.todayShort(self.start, format: "MM/dd/yyyy HH:mm")) to \(DateHelper.todayShort(self.end, format: "MM/dd/yyyy HH:mm"))",
                                page: self.state.session.appPage
                            )
                            FancyDivider()
                            LazyVGrid(columns: self.twoCol, alignment: .leading) {
                                GridRow {
                                    UI.SuggestedLinksInRange(
                                        period: .custom,
                                        start: self.start,
                                        end: self.end
                                    )
                                    UI.SavedSearchTermsInRange(
                                        period: .custom,
                                        start: self.start,
                                        end: self.end
                                    )
                                }
                            }
                            FancyDivider()
                            UI.InteractionsInRange(
                                period: .custom,
                                start: self.start,
                                end: self.end
                            )
                        }
                    }
                }

                // MARK: Timeline.ByEntity
                struct ByEntity: View {
                    @EnvironmentObject public var state: Navigation
                    @AppStorage("settings.accessibility.showUIHints") private var showUIHints: Bool = true
                    @State private var start: Date = Date()
                    @State private var end: Date = Date() + 86400
                    private var twoCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 2) }

                    var body: some View {
                        VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading) {
                                UI.SearchTypeFilter()
                            }
                            .background(self.state.session.appPage.primaryColour)
                            .clipShape(.rect(topTrailingRadius: 5))
                            .clipShape(.rect(bottomLeadingRadius: self.showUIHints ? 0 : 5, bottomTrailingRadius: self.showUIHints ? 0 : 5))
                            FancyHelpText(
                                text: "Show dates and times for the selected entities",
                                page: self.state.session.appPage
                            )
                            FancyDivider()
                            LazyVGrid(columns: self.twoCol, alignment: .leading) {
                                GridRow {
                                    DaysWhereMentioned()
                                    EmptyView()
                                }
                            }
                            FancyDivider()
                            ActivityFeed()
                        }
                    }
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
