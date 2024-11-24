//
//  WidgetLibrary.UI.Buttons.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-28.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension WidgetLibrary.UI {
    public struct Buttons {
        // Buttons which can be used by HistoryPage's to automatically add buttons to a page's top bar
        public enum UIButtonType {
            case resetUserChoices, createNote, createTask, createRecord, createPerson, createCompany, createProject,
                 createJob, createTerm, createDefinition, historyPrevious, settings, CLIMode, CLIFilter, sidebarToggle
        }

        struct ResetUserChoices: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var onActionClear: (() -> Void)?
            public var isAlteredForReadability: Bool = false

            var body: some View {
                FancyButtonv2(
                    text: "Reset interface to default state",
                    action: self.onActionClear != nil ? self.onActionClear : self.defaultClearAction,
                    icon: "arrow.clockwise.square.fill",
                    iconWhenHighlighted: "arrow.clockwise.square",
                    fgColour: self.viewModeIndex == 1 ? self.isAlteredForReadability ? Theme.base : .white : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .disabled(self.state.session.job == nil && self.state.session.project == nil && self.state.session.company == nil)
                .help("Reset interface to default state")
                .keyboardShortcut("r", modifiers: [.control, .shift])
                .frame(width: 25)
            }
        }

        struct CreateNote: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var onAction: (() -> Void)? = {}
            public var isAlteredForReadability: Bool = false

            var body: some View {
                FancyButtonv2(
                    text: "Create",
                    action: self.onAction,
                    icon: "plus.square.fill",
                    iconWhenHighlighted: "plus.square",
                    fgColour: self.viewModeIndex == 1 ? self.isAlteredForReadability ? Theme.base : .white : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    sidebar: AnyView(NoteCreateSidebar()),
                    font: .title
                )
                .help("Create a new note")
                .frame(width: 25)
            }
        }

        struct CreatePerson: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var onAction: (() -> Void)? = {}
            public var isAlteredForReadability: Bool = false

            var body: some View {
                FancyButtonv2(
                    text: "Create",
                    action: { self.onAction?() ; self.state.to(.peopleDetail) },
                    icon: "plus.square.fill",
                    iconWhenHighlighted: "plus.square",
                    fgColour: self.viewModeIndex == 1 ? self.isAlteredForReadability ? Theme.base : .white : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help("Create a new contact")
                .frame(width: 25)
            }
        }

        struct CreateCompany: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var onAction: (() -> Void)? = {}
            public var isAlteredForReadability: Bool = false

            var body: some View {
                FancyButtonv2(
                    text: "Create",
                    action: { self.onAction?() ; self.state.to(.companyDetail) },
                    icon: "plus.square.fill",
                    iconWhenHighlighted: "plus.square",
                    fgColour: self.viewModeIndex == 1 ? self.isAlteredForReadability ? Theme.base : .white : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help("Create a new company")
                .frame(width: 25)
            }
        }

        struct CreateProject: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var onAction: (() -> Void)? = {}
            public var location: WidgetLocation = .content
            public var isAlteredForReadability: Bool = false

            var body: some View {
                FancyButtonv2(
                    text: "Create",
                    action: { self.onAction?() ; self.state.to(.projectDetail) },
                    icon: self.location == .sidebar ? "folder.fill.badge.plus" : "plus.square.fill",
                    iconWhenHighlighted: self.location == .sidebar ? "folder.badge.plus" : "plus.square",
                    fgColour: self.viewModeIndex == 1 ? self.isAlteredForReadability ? Theme.base : .white : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: self.location == .sidebar ? .title2 : .title
                )
                .help("Create a new project")
                .frame(width: 25)
            }
        }

        struct CreateJob: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("jobdashboard.explorerVisible") private var explorerVisible: Bool = true
            @AppStorage("jobdashboard.editorVisible") private var editorVisible: Bool = true
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var isAlteredForReadability: Bool = false

            var body: some View {
                FancyButtonv2(
                    text: "Create",
                    action: self.actionOnTap,
                    icon: "plus.square.fill",
                    iconWhenHighlighted: "plus.square",
                    fgColour: self.viewModeIndex == 1 ? self.isAlteredForReadability ? Theme.base : .white : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help("Create a new job")
                .frame(width: 25)
            }
        }

        struct CreateTask: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var onAction: (() -> Void)? = {}
            public var isAlteredForReadability: Bool = false

            var body: some View {
                FancyButtonv2(
                    text: "Create",
                    action: { self.onAction?() ; self.state.to(.taskDetail) },
                    icon: "plus.square.fill",
                    iconWhenHighlighted: "plus.square",
                    fgColour: self.viewModeIndex == 1 ? self.isAlteredForReadability ? Theme.base : .white : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help("Create a new task")
                .frame(width: 25)
            }
        }

        struct CreateTerm: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var onAction: (() -> Void)? = {}
            public var isAlteredForReadability: Bool = false

            var body: some View {
                FancyButtonv2(
                    text: "Create",
                    action: { self.onAction?() ; self.state.to(.terms) },
                    icon: "plus.square.fill",
                    iconWhenHighlighted: "plus.square",
                    fgColour: self.viewModeIndex == 1 ? self.isAlteredForReadability ? Theme.base : .white : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help("Create a new taxonomy term")
                .frame(width: 25)
            }
        }

        struct CreateDefinition: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var onAction: (() -> Void)? = {}
            public var isAlteredForReadability: Bool = false

            var body: some View {
                FancyButtonv2(
                    text: "Create",
                    action: { self.onAction?() ; self.state.to(.definitionDetail) },
                    icon: "plus.square.fill",
                    iconWhenHighlighted: "plus.square",
                    fgColour: self.viewModeIndex == 1 ? self.isAlteredForReadability ? Theme.base : .white : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help("Create a new term definition")
                .frame(width: 25)
            }
        }

        struct CreateRecord: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var onAction: (() -> Void)? = {}
            public var isAlteredForReadability: Bool = false
            @State private var isHighlighted: Bool = false
            @State private var selectedPage: Page = .dashboard

            var body: some View {
                FancyButtonv2(
                    text: self.state.session.job != nil ? "Log to job \(self.state.session.job!.title ?? self.state.session.job!.jid.string)" : "Log",
                    action: self.onAction,
                    icon: "plus.square.fill",
                    iconWhenHighlighted: "plus.square",
                    fgColour: self.viewModeIndex == 1 ? self.isAlteredForReadability ? Theme.base : .white : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help("Create a new record")
                .frame(width: 25)
                .disabled(self.state.session.job == nil)
                .opacity(self.state.session.job == nil ? 0.5 : 1)
            }
        }

        struct CreateRecordToday: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var onAction: (() -> Void)? = {}
            public var isAlteredForReadability: Bool = false
            @State private var isHighlighted: Bool = false
            @State private var selectedPage: Page = .dashboard

            var body: some View {
                FancyButtonv2(
                    text: self.state.session.job != nil ? "Log to job \(self.state.session.job!.title ?? self.state.session.job!.jid.string)" : "Log",
                    action: {
                        self.onAction?()
                        self.state.to(.today)
                    },
                    icon: "plus.square.fill",
                    iconWhenHighlighted: "plus.square",
                    fgColour: self.viewModeIndex == 1 ? self.isAlteredForReadability ? Theme.base : .white : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help("Create a new record")
                .frame(width: 25)
                .disabled(self.state.session.job == nil)
                .opacity(self.state.session.job == nil ? 0.5 : 1)
            }
        }

        struct Minimize: View {
            @EnvironmentObject public var state: Navigation
            public var onAction: (() -> Void)? = {}
            public var font: Font = .title2
            @Binding public var isMinimized: Bool
            @State private var isHighlighted: Bool = false

            var body: some View {
                FancyButtonv2(
                    text: "",
                    action: {
                        self.onAction?()
                        self.isMinimized.toggle()
                    },
                    icon: !self.isMinimized ? "minus.square.fill" : "plus.square.fill",
                    iconWhenHighlighted: !self.isMinimized ? "minus.square" : "plus.square",
                    fgColour: .white,
                    showLabel: false,
                    size: .tiny,
                    type: .clear,
                    font: self.font
                )
                .padding([.top, .bottom], 10)
                .help("Create a new record")
                .frame(width: 25)
            }
        }

        struct HistoryPrevious: View {
            @EnvironmentObject public var state: Navigation
            public var onAction: (() -> Void)? = {}
            @State private var isHighlighted: Bool = false
            @State private var selectedPage: Page = .dashboard
            private var isEmpty: Bool { self.state.history.recent.count == 0 }

            var body: some View {
                Button {
                    if let previous = self.state.history.previous() {
                        self.state.to(previous.page, addToHistory: false)
                        self.selectedPage = previous.page
                        self.onAction?()
                    }
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .padding(8)
                    .background(self.state.session.appPage.primaryColour.opacity(self.isHighlighted ? 1 : 0.6))
                    .foregroundStyle(self.isHighlighted ? .white : Theme.lightWhite)
                    .clipShape(.rect(cornerRadius: 5))
                    .padding([.top, .bottom], 10)
                }
                .disabled(self.isEmpty)
                .keyboardShortcut(KeyEquivalent.leftArrow, modifiers: [.command])
                .buttonStyle(.plain)
                .useDefaultHover({ hover in !self.isEmpty ? self.isHighlighted = hover : nil})
            }
        }

        struct Settings: View {
            @EnvironmentObject public var state: Navigation
            public var onAction: (() -> Void)? = {}
            public var padding: CGFloat? = nil
            public var font: Font? = nil
            @State private var isHighlighted: Bool = false
            @State private var selectedPage: Page = .dashboard

            var body: some View {
                Button {
                    self.onAction?()
                } label: {
                    Image(systemName: "gear")
                        .font(self.font ?? .title)
                        .foregroundStyle(self.isHighlighted ? .white : Theme.lightWhite)
                        .padding([.leading, .trailing], self.padding ?? 20)
                        .padding([.top, .bottom], self.padding ?? 10)
                }
                .keyboardShortcut(KeyEquivalent.leftArrow, modifiers: [.command])
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover})
            }
        }

        struct CLIMode: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
            public var onAction: (() -> Void)? = {}
            @State private var isHighlighted: Bool = false
            @State private var selectedPage: Page = .dashboard

            var body: some View {
                FancyButtonv2(
                    text: "Command line mode",
                    action: {self.commandLineMode.toggle() ; self.onAction?()},
                    icon: self.commandLineMode ? "apple.terminal.fill" : "apple.terminal",
                    iconWhenHighlighted: self.commandLineMode ? "apple.terminal" : "apple.terminal.fill",
                    iconFgColour: self.commandLineMode ? self.state.theme.tint : .gray,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help(self.commandLineMode ? "Exit CLI mode" : "Enter CLI mode")
                .frame(width: 25)
            }
        }

        struct CLIFilter: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
            @AppStorage("today.cli.showFilter") private var showCLIFilter: Bool = false

            var body: some View {
                if self.commandLineMode {
                    FancyButtonv2(
                        text: "Filter",
                        action: {self.showCLIFilter.toggle()},
                        icon: "line.3.horizontal.decrease",
                        bgColour: self.state.session.appPage.primaryColour.opacity(0.2),
                        showLabel: false,
                        size: .small,
                        type: .clear
                    )
                    .mask(Circle())
                }
            }
        }

        struct Close: View {
            public var action: () -> Void
            public var font: Font = .title2

            var body: some View {
                FancyButtonv2(
                    text: "Reset",
                    action: self.action,
                    icon: "xmark.square.fill",
                    iconWhenHighlighted: "xmark.square",
                    showLabel: false,
                    size: .tiny,
                    type: .clear,
                    font: self.font
                )
                .frame(width: 18)
            }
        }

        struct SidebarToggle: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("widgetlibrary.ui.isSidebarPresented") private var isSidebarPresented: Bool = false

            var body: some View {
                FancyButtonv2(
                    text: "Toggle sidebar",
                    action: {self.isSidebarPresented.toggle()},
                    icon: "sidebar.left",
                    iconWhenHighlighted: "sidebar.left",
                    iconFgColour: self.isSidebarPresented ? self.state.theme.tint : .gray,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help("Toggle sidebar")
                .frame(width: 25)
            }
        }

        // MARK: RowActionButton
        struct RowActionButton: View {
            @EnvironmentObject public var state: Navigation
            public var callback: (() -> Void)
            public var icon: String?
            public var iconAsImage: Image?
            public var helpText: String = ""
            public var highlightedColour: Color = .yellow
            public var page: PageConfiguration.AppPage = .explore
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.callback()
                } label: {
                    ZStack(alignment: .center) {
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .leading, endPoint: .trailing)
                        self.isHighlighted ? self.highlightedColour : self.state.session.appPage.primaryColour

                        if let icon = self.icon {
                            Image(systemName: icon)
                                .symbolRenderingMode(.hierarchical)
                                .padding(5)
                        } else if let iconAsImage = self.iconAsImage {
                            iconAsImage
                                .symbolRenderingMode(.hierarchical)
                                .padding(5)
                        }
                    }
                    .foregroundStyle(self.isHighlighted ? Theme.base : self.highlightedColour)
                }
                .font(.headline)
                .buttonStyle(.plain)
                .help(self.helpText)
                .useDefaultHover({ hover in self.isHighlighted = hover })
            }
        }

        // MARK: SavedSearchTerm
        struct SavedSearchTerm: View {
            @EnvironmentObject public var state: Navigation
            public var savedSearch: SavedSearch
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.state.to(.dashboard)
                    if let term = self.savedSearch.term {
                        self.state.session.search.text = term
                    }
                } label: {
                    HStack {
                        Text(savedSearch.term ?? "Invalid term name")
                        Spacer()
                        if let timestamp = savedSearch.created?.formatted(date: .abbreviated, time: .shortened) {
                            Text(timestamp)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(8)
                    .background([.opaque, .hybrid].contains(self.state.theme.style) ? self.state.session.appPage.primaryColour.opacity(self.isHighlighted ? 1 : 0.9) : .white.opacity(self.isHighlighted ? 0.07 : 0.03))
                    .useDefaultHover({ hover in self.isHighlighted = hover })
                    .clipShape(.rect(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                .help("Searched for term \(savedSearch.created?.formatted(date: .complete, time: .complete) ?? "at some point in history")")
                .contextMenu {
                    VStack {
                        Button {
                            self.state.to(.timeline)
                            if let date = self.savedSearch.created {
                                self.state.session.date = date
                            }
                        } label: {
                            Text("Show Timeline...")
                        }
                        Button {
                            self.state.to(.today)
                            if let date = self.savedSearch.created {
                                self.state.session.date = date
                            }
                        } label: {
                            Text("Show Today...")
                        }
                    }
                }
            }
        }

        // MARK: SmallOpen
        struct SmallOpen: View {
            var callback: () -> Void
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.callback()
                } label: {
                    Text("Open")
                        .font(.caption)
                        .foregroundStyle(Theme.base)
                        .padding(6)
                        .padding([.leading, .trailing], 8)
                        .background(.white.opacity(self.isHighlighted ? 1 : 0.8))
                        .clipShape(.capsule(style: .continuous))
                }
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover})
            }
        }

        // MARK: Buttons.FooterActivity
        struct FooterActivity: View {
            @EnvironmentObject private var state: Navigation

            var start: Date?
            var end: Date?
            var label: String
            var icon: String
            @AppStorage("widgetlibrary.ui.appfooter.isMinimized") private var isMinimized: Bool = false
            @State private var isHighlighted: Bool = false
            @State private var count: Int = 0

            var body: some View {
                Button {
                    self.isMinimized.toggle()
                } label: {
                    HStack(spacing: 0) {
                        Image(systemName: self.icon)
                            .foregroundStyle(.white)
                            .padding(8)
                        Text("\(self.count) \(self.label)")
                            .bold(self.count > 0)
                            .padding(8)
                            .background(Theme.lightWhite)
                            .foregroundStyle(Theme.base)
                            .underline(self.isHighlighted)
                    }
                    .background(self.state.session.appPage.primaryColour)
                    .clipShape(.capsule(style: .circular))
                }
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover })
                .help("\(self.count) \(self.label) on \(self.state.session.dateFormatted("MMMM dd, yyyy"))")
                .onAppear(perform: self.actionOnAppear)
            }
        }

        // MARK: Buttons.CopyRecordsToClipboard
        struct CopyRecordsToClipboard: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("settings.accessibility.showSelectorLabels") private var showSelectorLabels: Bool = true
            public var records: [LogRecord]?
            @State private var isPresented: Bool = false
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button(action: self.actionOnCopy, label: {
                    HStack(spacing: 5) {
                        Image(systemName: "document.on.document.fill")
                            .foregroundStyle(self.state.theme.tint)
                        if self.showSelectorLabels {
                            Text("Copy")
                        }
                    }
                    .padding(6)
                    .background(Theme.textBackground)
                    .foregroundStyle(Theme.lightWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                })
                .buttonStyle(.plain)
                .keyboardShortcut("c", modifiers: [.control, .shift])
                .help("Copy view data to clipboard")
                .useDefaultHover({ hover in self.isHighlighted = hover})
            }
        }

        // MARK: Buttons.ExportToCSV
        struct ExportToCSV: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("settings.accessibility.showSelectorLabels") private var showSelectorLabels: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showRecords") public var showRecords: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showNotes") public var showNotes: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showTasks") public var showTasks: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showProjects") public var showProjects: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showJobs") public var showJobs: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showCompanies") public var showCompanies: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showPeople") public var showPeople: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showTerms") public var showTerms: Bool = true
            @AppStorage("widgetlibrary.ui.searchTypeFilter.showDefinitions") public var showDefinitions: Bool = true
            @AppStorage("today.showColumnIndex") public var showColumnIndex: Bool = true
            @AppStorage("today.showColumnTimestamp") public var showColumnTimestamp: Bool = true
            @AppStorage("today.showColumnJobId") public var showColumnJobId: Bool = true
            public var records: [LogRecord]
            public var timelineActivities: [GenericTimelineActivity]
            public var activities: [Activity]
            public var tab: String
            @State private var isPresented: Bool = false
            @State private var isHighlighted: Bool = false
            @State private var csv: CSVFileDocument = CSVFileDocument(initialText: "")
            @State private var csvFileName: String = ""

            var body: some View {
                Button(action: self.actionOnExportToCSV, label: {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.down.document.fill")
                            .foregroundStyle(self.state.theme.tint)
                        if self.showSelectorLabels {
                            Text("CSV")
                        }
                    }
                    .padding(6)
                    .background(Theme.textBackground)
                    .foregroundStyle(Theme.lightWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                })
                .disabled(self.records.isEmpty && self.timelineActivities.isEmpty && self.activities.isEmpty)
                .buttonStyle(.plain)
                .keyboardShortcut("c", modifiers: [.control, .shift])
                .help("Export table as CSV")
                .useDefaultHover({ hover in self.isHighlighted = hover})
                .fileExporter(isPresented: self.$isPresented, document: self.csv, contentType: .commaSeparatedText, defaultFilename: self.csvFileName) { result in
                    switch result {
                    case .success(let url):
                        print("DERPO Saved to \(url)")
                    case .failure(let error):
                        print("DERPO \(error.localizedDescription)")
                    }
                }
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.state.session.date) { self.actionOnAppear() }
            }

            // MARK: Buttons.ExportToCSV.Column
            struct Column: Identifiable, Equatable {
                var id: UUID = UUID()
                var text: String
            }

            // MARK: Buttons.ExportToCSV.Line
            struct Line: Identifiable {
                var id: UUID = UUID()
                var columns: [Column]
                var toString: String {
                    var out: String = ""
                    for column in self.columns {
                        out += "\(column.text)"

                        if column != self.columns.last {
                            out += ","
                        }
                    }
                    return out
                }
            }

            // MARK: Buttons.ExportToCSV.CSVFile
            class CSVFile: Identifiable {
                var id: UUID = UUID()
                var toString: String {
                    var out: String = ""
                    for line in self.lines {
                        out += "\(line.toString)\n"
                    }
                    return out
                }
                private var lines: [Line] = []
                
                /// Add a line by passing a bunch of columns
                /// - Parameter columns: Array<Column>
                /// - Returns: Void
                public func addLine(columns: [Column]) -> Void {
                    self.lines.append(
                        Line(columns: columns)
                    )
                }
                
                /// Add a pre-constructed Line
                /// - Parameter line: Line
                /// - Returns: Void
                public func addLine(line: Line) -> Void {
                    self.lines.append(line)
                }
                
                /// Create a CSVFileDocument for the fileExporter API
                /// - Returns: CSVFileDocument
                public func document() -> CSVFileDocument {
                    return CSVFileDocument(initialText: self.toString)
                }
            }
        }
    }
}

extension WidgetLibrary.UI.Buttons.CopyRecordsToClipboard {
    /// Copy data to clipboard
    /// - Returns: Void
    private func actionOnCopy() -> Void {
        if let records = self.records {
            ClipboardHelper.copy(
                CoreDataRecords(moc: self.state.moc).createExportableRecordsFrom(records)
            )
        }
    }
}

extension WidgetLibrary.UI.Buttons.ExportToCSV {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.csvFileName = "\(self.state.session.appPage)-\(self.tab)-\(DateHelper.todayShort(self.state.session.timeline.date ?? self.state.session.date, format: "d/M/yyyy.HHmm"))"
    }

    /// Creates a CSV representation of the current list of records
    /// - Returns: Void
    private func actionOnExportToCSV() -> Void {
        self.isPresented = true
        let file: CSVFile = CSVFile()

        if !self.records.isEmpty {
            if self.showRecords {
                for record in records {
                    file.addLine(line: self.lineForRecord(record))
                }
            }
        } else if !self.timelineActivities.isEmpty {
            for activity in self.timelineActivities {
                if let entity = activity.entity as? LogRecord {
                    if self.showRecords {
                        file.addLine(line: self.lineForRecord(entity))
                    }
                } else if let entity = activity.entity as? LogTask {
                    if self.showTasks {
                        file.addLine(line: self.lineForTask(entity))
                    }
                } else if let entity = activity.entity as? Note {
                    if self.showNotes {
                        file.addLine(line: self.lineForNote(entity))
                    }
                }
            }
        } else if !self.activities.isEmpty {
            for activity in self.activities {
                if let entity = activity.source as? LogRecord {
                    if self.showRecords {
                        file.addLine(line: self.lineForRecord(entity))
                    }
                } else if let entity = activity.source as? LogTask {
                    if self.showTasks {
                        file.addLine(line: self.lineForTask(entity))
                    }
                } else if let entity = activity.source as? Note {
                    if self.showNotes {
                        file.addLine(line: self.lineForNote(entity))
                    }
                }
            }
        }

        self.csv = file.document()
    }

    /// Creates a Line representation of a Note object
    /// - Parameter record: LogRecord
    /// - Returns: Line
    private func lineForNote(_ entity: Note) -> Line {
        var columns: [Column] = []
        if self.showColumnTimestamp {
            columns.append(Column(text: (entity.postedDate ?? Date.now).formatted()))
        }
        if self.showColumnJobId {
            columns.append(Column(text: entity.mJob?.title ?? entity.mJob?.jid.string ?? "Invalid job"))
        }
        columns.append(Column(text: entity.title ?? "Invalid note title"))
        return Line(columns: columns)
    }

    /// Creates a Line representation of a LogRecord object
    /// - Parameter record: LogRecord
    /// - Returns: Line
    private func lineForRecord(_ entity: LogRecord) -> Line {
        var columns: [Column] = []
        if self.showColumnTimestamp {
            columns.append(Column(text: (entity.timestamp ?? Date.now).formatted()))
        }
        if self.showColumnJobId {
            columns.append(Column(text: entity.job?.title ?? entity.job?.jid.string ?? "Invalid job"))
        }
        if entity.message != nil {
            // Apply banned word filter to LogRecord
            let cleaned = CoreDataProjectConfiguration.applyBannedWordsTo(entity)
            // @TODO: find a better method for generating this string that doesn't involve string replace, if possible
            columns.append(Column(text: "\(cleaned.message?.replacingOccurrences(of: ",", with: "") ?? "Invalid record content")"))
        }

        return Line(columns: columns)
    }

    /// Creates a Line representation of a LogTask object
    /// - Parameter task: LogTask
    /// - Returns: Line
    private func lineForTask(_ entity: LogTask) -> Line {
        var columns: [Column] = []
        var taskStatusPrefix: String = ""

        // Task is unmodified since posting
        if entity.created == entity.lastUpdate {
            if self.showColumnTimestamp {
                taskStatusPrefix = "Updated task"
                columns.append(Column(text: (entity.lastUpdate ?? Date.now).formatted()))
            }
        } else if entity.completedDate != nil {
            // Task was completed
            if self.showColumnTimestamp {
                taskStatusPrefix = "Complete task"
                columns.append(Column(text: (entity.completedDate ?? Date.now).formatted()))
            }
        } else if entity.cancelledDate != nil {
            // Task was cancelled
            if self.showColumnTimestamp {
                taskStatusPrefix = "Cancelled task"
                columns.append(Column(text: (entity.cancelledDate ?? Date.now).formatted()))
            }
        } else {
            taskStatusPrefix = "Created task"
            columns.append(Column(text: (entity.created ?? Date.now).formatted()))
        }
        if self.showColumnJobId {
            columns.append(Column(text: entity.owner?.title ?? entity.owner?.jid.string ?? "Invalid job"))
        }
        columns.append(Column(text: "\(taskStatusPrefix): \(entity.content ?? "Invalid task content")"))

        return Line(columns: columns)
    }
}

extension WidgetLibrary.UI.Buttons.FooterActivity {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        // @TODO: still fucked after rewrite, investigate
        // https://www.avanderlee.com/concurrency/tasks/
//        if self.start != nil && self.end != nil {
//            let fromRecords = Task { return await CoreDataRecords(moc: self.state.moc).links(start: self.start!, end: self.end!) }
//            let fromTasks = Task { return await CoreDataTasks(moc: self.state.moc).links(start: self.start!, end: self.end!) }
//            let fromNotes = Task { return await CoreDataNotes(moc: self.state.moc).links(start: self.start!, end: self.end!) }
//            let fromJobs = Task { return await CoreDataJob(moc: self.state.moc).links(start: self.start!, end: self.end!) }
//
//            Task {
//                self.count += (await fromRecords.value).count
//                self.count += (await fromTasks.value).count
//                self.count += (await fromNotes.value).count
//                self.count += (await fromJobs.value).count
//            }
//        }
    }
}

extension WidgetLibrary.UI.Buttons.ResetUserChoices {
    private func defaultClearAction() -> Void {
        self.state.session.job = nil
        self.state.session.project = nil
        self.state.session.company = nil
    }
}

extension WidgetLibrary.UI.Buttons.CreateJob {
    /// Fires when the button is clicked/tapped.
    /// - Returns: Void
    private func actionOnTap() -> Void {
        self.editorVisible = true
        self.explorerVisible = false

        // Creates a new job entity so the user can customize it
        // @TODO: move to new method CoreDataJobs.create
        let newJob = Job(context: self.state.moc)
        newJob.id = UUID()
        newJob.jid = 1.0
        newJob.colour = Color.randomStorable()
        newJob.alive = true
        newJob.project = CoreDataProjects(moc: self.state.moc).alive().first(where: {$0.company?.isDefault == true})
        newJob.created = Date()
        newJob.lastUpdate = newJob.created
        newJob.overview = "Sample job overview"
        newJob.title = "Sample job title"
        self.state.session.job = newJob
        self.state.forms.tp.editor.job = newJob
    }
}
