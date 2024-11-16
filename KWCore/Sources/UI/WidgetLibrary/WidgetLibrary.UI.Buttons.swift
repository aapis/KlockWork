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
            @AppStorage("general.usingBackgroundImage") private var usingBackgroundImage: Bool = false
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
                    .background(self.usingBackgroundImage ? self.state.session.appPage.primaryColour.opacity(self.isHighlighted ? 1 : 0.9) : .white.opacity(self.isHighlighted ? 0.07 : 0.03))
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
