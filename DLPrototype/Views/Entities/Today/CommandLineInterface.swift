//
//  CommandLineInterface.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-05-14.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct CommandLineInterface: View {
    static private let maxItems: Int = 500
    
    @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
    
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            Display()
            Prompt()
        }
        .background(Theme.textBackground)
    }
}

#Preview {
    CommandLineInterface()
}

extension CommandLineInterface {
    struct App {
        var id: UUID = UUID()
        var type: AppType
        var action: () -> Void
        var promptPlaceholder: String
        
        enum AppType: CaseIterable {
            case log, query
            
            var fgColour: Color {
                .white
            }
            
            var bgColour: Color {
                switch self {
                case .log: .blue
                case .query: .red
                }
            }
            
            var name: String {
                switch self {
                case .log: "log"
                case .query: "query"
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
                    ForEach(nav.session.cli.history) { line in
                        HStack {
                            Text("[\(line.time.formatted(date: .abbreviated, time: .complete))]")
                                .foregroundStyle(.gray)
                            Text(line.command)
                            Spacer()
                        }
                    }
                }
            }
            .padding([.leading, .trailing, .bottom])
            .font(Theme.fontTextField)
        }
    }
    
    struct Prompt: View {
        @State public var command: String = ""
        
        @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
        
        @FocusState private var primaryTextFieldInFocus: Bool
        
        @EnvironmentObject public var nav: Navigation
        
        var body: some View {
            ZStack {
                HStack(spacing: 0) {
                    Text("$")
                        .padding([.leading, .top, .bottom])
                        .background(Theme.textBackground)
                        .font(.title2)

                    AppSelector()

                    FancyTextField(
                        placeholder: "What are you working on?",
                        onSubmit: execute,
                        font: .title2,
                        text: $command
                    )
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
    }
}

extension CommandLineInterface.Prompt {
    struct AppSelector: View {
        typealias CLIApp = CommandLineInterface.App
        
        private var apps: [CLIApp] = [
            CLIApp(type: .log, action: {}, promptPlaceholder: "What are you working on?"),
            CLIApp(type: .query, action: {}, promptPlaceholder: "Find stuff"),
        ]
        
        @State private var selected: CLIApp.AppType = .log

        var body: some View {
            Text("log")
                .padding([.top, .bottom, .leading])
                .background(Theme.textBackground)
                .font(.title2)
        }
    }
}

extension CommandLineInterface.Prompt {
    private func execute() -> Void {
        if nav.session.cli.history.count <= CommandLineInterface.maxItems {
            if nav.session.job == nil {
                command = "ERROR: select a job first"
            }
            
            nav.session.cli.history.append(
                Navigation.CommandLineSession.History(command: command)
            )
            
            nav.session.cli.command = nil
            command = ""
        }
    }
}
