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
                if self.state.session.job != nil || self.state.session.project != nil || self.state.session.company != nil {
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
                    .help("Reset interface to default state")
                    .frame(width: 25)
                } else {
                    EmptyView()
                }
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
            @State private var isHighlighted: Bool = false
            @State private var selectedPage: Page = .dashboard

            var body: some View {
                Button {
                    self.onAction?()
                } label: {
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundStyle(self.isHighlighted ? .white : Theme.lightWhite)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 10)
                }
                .keyboardShortcut(KeyEquivalent.leftArrow, modifiers: [.command])
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover})
            }
        }

        struct CLIMode: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("general.experimental.cli") private var cliEnabled: Bool = false
            @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
            public var onAction: (() -> Void)? = {}
            @State private var isHighlighted: Bool = false
            @State private var selectedPage: Page = .dashboard

            var body: some View {
                if self.cliEnabled {
                    FancyButtonv2(
                        text: "Command line mode",
                        action: {self.commandLineMode.toggle() ; self.onAction?()},
                        icon: self.commandLineMode ? "apple.terminal.fill" : "apple.terminal",
                        iconWhenHighlighted: self.commandLineMode ? "apple.terminal" : "apple.terminal.fill",
                        showLabel: false,
                        size: .small,
                        type: .clear,
                        font: .title
                    )
                    .help(self.commandLineMode ? "Exit CLI mode" : "Enter CLI mode")
                    .frame(width: 25)
                }
            }
        }

        struct CLIFilter: View {
            @EnvironmentObject public var state: Navigation
            @AppStorage("general.experimental.cli") private var cliEnabled: Bool = false
            @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
            @AppStorage("today.cli.showFilter") private var showCLIFilter: Bool = false

            var body: some View {
                if self.cliEnabled && self.commandLineMode {
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

            var body: some View {
                FancyButtonv2(
                    text: "Reset",
                    action: self.action,
                    icon: "xmark.square.fill",
                    iconWhenHighlighted: "xmark.square",
                    showLabel: false,
                    type: .clear,
                    font: .title2
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
                    fgColour: self.isSidebarPresented ? .gray : .white,
                    showLabel: false,
                    size: .small,
                    type: .clear,
                    font: .title
                )
                .help("Toggle sidebar")
                .frame(width: 25)
            }
        }
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