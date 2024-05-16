//
//  CommandLineInterface.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-05-14.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct CommandLineInterface: View {
    typealias CLIApp = CommandLineInterface.App
    typealias Status = Navigation.CommandLineSession.History.Status

    static private let maxItems: Int = 500

    @State private var validSetCommands: [CLICommand] = []
    @State private var apps: [CLIApp] = []
    @State private var selected: CLIApp.AppType = .log
    @State private var command: String = ""
    @State private var showSelectorPanel: Bool = false
    
    @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
    @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearching: Bool = false
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Display()
            
            // Prompt
            if showSelectorPanel {
                CommandLineInterface.AppSelectorPanel(apps: apps)
            }
            
            ZStack {
                ForEach(apps) { app in
                    if app.type == selected {
                        app
                    }
                }
                HStack {
                    Spacer()
                    FancyButtonv2(
                        text: "Exit CLI mode",
                        action: {commandLineMode.toggle()},
                        icon: "apple.terminal",
                        fgColour: .white,
                        showLabel: false,
                        size: .tiny,
                        type: .clear
                    )
                    .help("Exit CLI mode")
                    .frame(width: 30, height: 30)
                }
                .padding(.trailing)
            }
        }
        .background(Theme.textBackground)
        .onAppear(perform: actionOnAppear)
    }
}

extension CommandLineInterface {
    private func executeLogAction() -> Void {
        var line: Navigation.CommandLineSession.History
        
        if command == "help" {
            line = Navigation.CommandLineSession.History(
                command: command,
                status: nav.session.job == nil ? .error : .standard,
                message: apps.filter({$0.type == selected}).first?.helpText ?? "Help text",
                appType: selected
            )
        } else {
            line = Navigation.CommandLineSession.History(
                command: command,
                status: nav.session.job == nil ? .error : .standard,
                message: nav.session.job == nil ? "You must select a job first" : "",
                appType: selected
            )
        }
        
        self.updateDisplay(line: line)
        
        Task {
            // @TODO: copied from PostingInterface.save, refactor!
            if let job = nav.session.job {
                let record = LogRecord(context: moc)
                record.timestamp = Date()
                record.message = command
                record.alive = true
                record.id = UUID()
                record.job = job
                
                do {
                    try record.validateForInsert()

                    PersistenceController.shared.save()
                    nav.session.idate = DateHelper.identifiedDate(for: Date(), moc: moc)
                } catch {
                    print("[debug][error] Save error \(error)")
                }
            }

            self.clear()
        }
    }
    
    private func executeQueryAction() -> Void {
        self.updateDisplay(status: .standard, message: command)
        self.clear()
    }
    
    private func executeSetAction() -> Void {
        var line: Navigation.CommandLineSession.History = Navigation.CommandLineSession.History(
            command: command,
            status: .standard,
            message: "",
            appType: selected
        )
        
        if command == "help" {
            line.message = apps.filter({$0.type == selected}).first?.helpText ?? "Help text"
        }
        
        Task {
            let pattern = /^@(.*?)\.(.*?)=(\d+)/
            let matches = command.matches(of: pattern)

            if let match = matches.first {
                // We found a matching CLICommand, execute it
                if let cmd = validSetCommands.first(where: {$0.domain == match.1 && $0.method == match.2}) {
                    // Run the callback, successful response messages is defined there
                    cmd.callback(String(match.3), &line)
                } else {
                    line.message = "Invalid command: @\(String(match.1)).\(String(match.2))"
                    line.status = .error
                }
            }

            self.updateDisplay(line: line)
            self.clear()
        }
    }
    
    private func actionOnAppear() -> Void {
        self.apps = [
            CLIApp(
                type: .log,
                action: self.executeLogAction,
                promptPlaceholder: "What are you working on?",
                helpText: "Write out what you're working on right now, like right-right now, and hit return.",
                showSelectorPanel: $showSelectorPanel,
                command: $command,
                selected: $selected
            ),
            // @TODO: not ready for primetime yet
//            CLIApp(
//                type: .query,
//                action: self.executeQueryAction,
//                promptPlaceholder: "Find stuff",
//                showSelectorPanel: $showSelectorPanel, helpText: String,
//                command: $command,
//                selected: $selected
//            ),
            CLIApp(
                type: .set,
                action: self.executeSetAction,
                promptPlaceholder: "Configure things",
                helpText: "Syntax: @session.job=100 @inspect.job=100",
                showSelectorPanel: $showSelectorPanel,
                command: $command,
                selected: $selected
            )
        ]
        
        self.validSetCommands = [
            CLICommand(domain: "session", method: "job", callback: { match, line in
                let id: Double = Double(match) ?? 0.0
                if let job = CoreDataJob(moc: moc).byId(id) {
                    nav.session.setJob(job)
                    line.status = .success
                } else {
                    line.message = "Unable to find a Job with ID \(match)"
                    line.status = .error
                }
            }),
            CLICommand(domain: "inspect", method: "job", callback: { match, line in
                let id: Double = Double(match) ?? 0.0
                if let job = CoreDataJob(moc: moc).byId(id) {
                    isSearching = true
                    nav.session.search.text = job.jid.string
                    nav.session.search.inspectingEntity = job
                    nav.setInspector(AnyView(Inspector(entity: job)))
                    
                    line.status = .success
                } else {
                    line.message = "Unable to find a Job with ID \(match)"
                    line.status = .error
                }
            })
        ]
    }
    
    private func clear() -> Void {
        let defaultCallback: () -> Void = {
            nav.session.cli.command = nil
            command = ""
        }
        
        // Handle special commands
        switch command {
        case "exit": commandLineMode.toggle()
        case "reset": nav.session.setJob(nil)
        default:
            defaultCallback()
        }

        defaultCallback()
    }
    
    private func updateDisplay(status: Status, message: String) -> Void {
        if nav.session.cli.history.count <= CommandLineInterface.maxItems {
            var item: Navigation.CommandLineSession.History
            
            switch nav.session.cli.app {
            case .log:
                item = Navigation.CommandLineSession.History(
                    command: command,
                    status: nav.session.job == nil ? .error : .standard,
                    message: nav.session.job == nil ? "You must select a job first" : "",
                    appType: selected
                )
            case .set:
                item = Navigation.CommandLineSession.History(
                    command: command,
                    status: .standard,
                    message: "",
                    appType: selected
                )
            case .query:
                item = Navigation.CommandLineSession.History(
                    command: command,
                    status: .standard,
                    message: "",
                    appType: selected
                )
            }
            
            nav.session.cli.history.append(item)
        }
    }
    
    private func updateDisplay(line: Navigation.CommandLineSession.History) -> Void {
        if nav.session.cli.history.count <= CommandLineInterface.maxItems {
            nav.session.cli.history.append(line)
        }
    }
}

#Preview {
    CommandLineInterface()
}

extension CommandLineInterface {
    struct CLICommand {
        var domain: String
        var method: String
        var callback: (String, inout Navigation.CommandLineSession.History) -> Void
    }
    
    struct App: View, Identifiable {
        var id: UUID = UUID()
        var type: AppType
        var action: () -> Void
        var promptPlaceholder: String
        var helpText: String
        
        @Binding public var showSelectorPanel: Bool
        @Binding public var command: String
        @Binding public var selected: AppType

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            HStack(spacing: 0) {
                CommandLineInterface.AppSelectorButton(type: type, showSelectorPanel: $showSelectorPanel, selected: $selected)
                
                FancyTextField(
                    placeholder: promptPlaceholder,
                    onSubmit: action,
                    fgColour: nav.session.job?.backgroundColor.isBright() ?? false ? .black : .white,
                    bgColour: nav.session.job?.backgroundColor ?? Theme.textBackground,
                    font: Theme.fontTextField,
                    text: $command
                )
                .disabled(showSelectorPanel)
            }
            .onAppear(perform: actionOnAppear)
        }
        
        private func actionOnAppear() -> Void {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
                let code = Int($0.keyCode)
                
                if code == 125 {
                    command = ""
                } else if code == 126 {
                    if let last = nav.session.cli.history.last {
                        command = last.command
                    }
                }
                return $0
            }
        }
        
        enum AppType: CaseIterable, Identifiable {
            case log, query, set
            
            var id: UUID {
                UUID()
            }
            
            var fgColour: Color {
                .white
            }
            
            var bgColour: Color {
                switch self {
                case .log: Theme.cPurple
                case .query: Theme.cYellow
                case .set: Theme.cOrange
                }
            }
            
            var name: String {
                switch self {
                case .log: "log"
                case .query: "query"
                case .set: "set"
                }
            }
        }
    }
    
    struct Display: View {
        @EnvironmentObject public var nav: Navigation
        
        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                Spacer()
                ScrollView {
                    VStack(spacing: 1) {
                        ForEach(nav.session.cli.history) { line in
                            VStack(alignment: .leading, spacing: 1) {
                                HStack {
                                    line.status.icon
                                        .foregroundStyle(line.status.colour)
                                    
                                    Text("[\(line.time.formatted(date: .abbreviated, time: .complete))]")
                                        .foregroundStyle(.gray)
                                    Text(line.appType.name)
                                        .background(line.appType.bgColour)
                                        .foregroundStyle(line.appType.fgColour)

                                    Text(line.command)
                                    Spacer()
                                }

                                if !line.message.isEmpty {
                                    HStack {
                                        Image(systemName: "arrow.turn.down.right")
                                            .padding([.leading], 8)
                                        Text(line.message)
                                    }
                                    .foregroundStyle(line.status.colour)
                                }
                            }
                        }
                    }
                }
            }
            .padding([.leading, .trailing, .bottom])
            .font(Theme.fontTextField)
        }
    }
    
    struct AppSelectorButton: View {
        typealias CLIApp = CommandLineInterface.App
        
        public var type: CLIApp.AppType
        @Binding public var showSelectorPanel: Bool
        @Binding public var selected: CLIApp.AppType
        
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            Button {
                showSelectorPanel.toggle()
                selected = type
                nav.session.cli.app = type
            } label: {
                Text("$ \(type.name)")
                    .padding()
                    .background(type.bgColour)
                    .foregroundStyle(type.fgColour)
            }
            .buttonStyle(.plain)
            .useDefaultHover({_ in})
        }
    }
    
    struct AppSelectorPanel: View {
        typealias CLIApp = CommandLineInterface.App
        
        public var apps: [CLIApp]
        
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                Text("Choose an app from the list")
                    .padding()

                ForEach(apps) { app in
                    app
                }
            }
        }
    }
}
