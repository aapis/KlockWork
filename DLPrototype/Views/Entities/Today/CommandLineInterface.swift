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
    
    @State private var apps: [CLIApp] = []
    @State private var selected: CLIApp.AppType = .log
    @State private var command: String = ""
    @State private var showSelectorPanel: Bool = false
    
    @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
    
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
        let line = Navigation.CommandLineSession.History(
            command: command,
            status: nav.session.job == nil ? .error : .standard,
            message: nav.session.job == nil ? "You must select a job first" : "",
            appType: selected
        )
        
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
        self.updateDisplay(status: .standard, message: "Searching for X")
        self.clear()
    }
    
    private func executeSetAction() -> Void {
        self.updateDisplay(status: .standard, message: "Set X = Y")
        self.clear()
    }
    
    private func actionOnAppear() -> Void {
        self.apps = [
            CLIApp(
                type: .log,
                action: self.executeLogAction,
                promptPlaceholder: "What are you working on?",
                showSelectorPanel: $showSelectorPanel,
                command: $command,
                selected: $selected
            ),
            // @TODO: not ready for primetime yet
//            CLIApp(
//                type: .query,
//                action: self.executeQueryAction,
//                promptPlaceholder: "Find stuff",
//                showSelectorPanel: $showSelectorPanel,
//                command: $command,
//                selected: $selected
//            ),
//            CLIApp(
//                type: .set,
//                action: self.executeSetAction,
//                promptPlaceholder: "Configure things",
//                showSelectorPanel: $showSelectorPanel,
//                command: $command,
//                selected: $selected
//            )
        ]
    }
    
    private func clear() -> Void {
        // @TODO: expand to include some "quick" commands like exit
        if command == "exit" {
            commandLineMode.toggle()
        }
        
        nav.session.cli.command = nil
        command = ""
    }
    
    private func updateDisplay(status: Status, message: String) -> Void {
        if nav.session.cli.history.count <= CommandLineInterface.maxItems {
            nav.session.cli.history.append(
                Navigation.CommandLineSession.History(
                    command: command,
                    status: nav.session.job == nil ? .error : .standard,
                    message: nav.session.job == nil ? "You must select a job first" : "",
                    appType: selected
                )
            )
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
    struct App: View, Identifiable {
        var id: UUID = UUID()
        var type: AppType
        var action: () -> Void
        var promptPlaceholder: String
        
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
                    bgColour: nav.session.job?.backgroundColor ?? Theme.textBackground,
                    font: .title2,
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
                                
                                if [.error, .warning].contains(line.status) {
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

        var body: some View {
            Button {
                showSelectorPanel.toggle()
                selected = type
            } label: {
                HStack {
                    Text("$")
                        .padding([.leading, .top, .bottom])
                        .font(.title2)
                    
                    Text(type.name)
                        .padding([.top, .bottom, .trailing])
                        .font(.title2)
                }
                .background(type.bgColour)
                .foregroundStyle(type.fgColour)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct AppSelectorPanel: View {
        typealias CLIApp = CommandLineInterface.App
        
        public var apps: [CLIApp]

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
