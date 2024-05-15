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
    @State public var command: String = ""
    
    @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
    
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            Display()
            
            // Prompt
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
        self.updateDisplay(
            status: nav.session.job == nil ? .error : .standard,
            message: nav.session.job == nil ? "You must select a job first" : ""
        )
        
        self.clear()
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
            CLIApp(type: .log, action: self.executeLogAction, promptPlaceholder: "What are you working on?", command: $command),
            CLIApp(type: .query, action: self.executeQueryAction, promptPlaceholder: "Find stuff", command: $command),
            CLIApp(type: .set, action: self.executeSetAction, promptPlaceholder: "Configure things", command: $command)
        ]
    }
    
    private func clear() -> Void {
        nav.session.cli.command = nil
        command = ""
    }
    
    private func updateDisplay(status: Status, message: String) -> Void {
        if nav.session.cli.history.count <= CommandLineInterface.maxItems {
            nav.session.cli.history.append(
                Navigation.CommandLineSession.History(
                    command: command,
                    status: nav.session.job == nil ? .error : .standard,
                    message: nav.session.job == nil ? "You must select a job first" : ""
                )
            )
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
        
        @Binding public var command: String
        
        var body: some View {
            HStack(spacing: 0) {
                Text("$")
                    .padding([.leading, .top, .bottom])
                    .background(Theme.textBackground)
                    .font(.title2)
                
                CommandLineInterface.AppSelector(selected: type)
                
                FancyTextField(
                    placeholder: promptPlaceholder,
                    onSubmit: action,
                    font: .title2,
                    text: $command
                )
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
                case .log: .blue
                case .query: .red
                case .set: .orange
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
    
    struct AppSelector: View {
        typealias CLIApp = CommandLineInterface.App
        
        public var selected: CLIApp.AppType

        var body: some View {
            Text(selected.name)
                .padding([.top, .bottom, .leading])
                .background(Theme.textBackground)
                .font(.title2)
        
        }
    }
}
