//
//  PostingInterface.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-25.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Today {
    struct PostingInterface: View {
        @State private var text: String = ""
        @State private var errorNoJob: Bool = false
        @State private var errorNoContent: Bool = false
        @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
        @AppStorage("general.experimental.cli") private var allowCLIMode: Bool = false

        @FocusState private var primaryTextFieldInFocus: Bool

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation
        private let page: PageConfiguration.AppPage = .today
        private let eType: PageConfiguration.EntityType = .records

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                UniversalHeader.Widget(
                    type: self.eType,
                    buttons: AnyView(Buttons(text: $text, onActionSubmit: self.submitAction, onActionClear: self.clearAction))
                )

                FancyTextField(
                    placeholder: "What are you working on?",
                    lineLimit: 11,
                    onSubmit: submitAction,
                    fgColour: self.nav.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
                    text: $text
                )
                .background(self.nav.session.job?.backgroundColor.opacity(0.6) ?? .clear)
                .focused($primaryTextFieldInFocus)
                .onAppear {
                    // thx https://www.kodeco.com/31569019-focus-management-in-swiftui-getting-started#toc-anchor-002
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.primaryTextFieldInFocus = true
                    }
                }
                .alert("Please select a job from the sidebar", isPresented: $errorNoJob) {
                    Button("Ok", role: .cancel) {}
                }
                .alert("You need to write a message too. What are you working on?", isPresented: $errorNoContent) {
                    Button("Ok", role: .cancel) {}
                }
                .frame(height: 215)

                FancyHelpText(
                    text: "Choose a job from the sidebar, type into the field below. Enter/Return/+ to create records.",
                    page: self.page
                )
            }
            .onChange(of: text) {
                if self.text.isEmpty {
                    nav.save()
//                    nav.state.on(.ready, { _ in
//                        nav.save()
//                    })
//                    let _ = nav.state.advance()
//                    nav.save()
                }
            }
        }

        struct Buttons: View {
            typealias Widget = WidgetLibrary.UI.Buttons
            @EnvironmentObject public var state: Navigation
            @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
            @AppStorage("general.experimental.cli") private var allowCLIMode: Bool = false
            @State private var errorNoJob: Bool = false
            @State private var errorNoContent: Bool = false
            private let page: PageConfiguration.AppPage = .today
            @Binding public var text: String
            public var onActionSubmit: (() -> Void) = {}
            public var onActionClear: (() -> Void) = {}

            var body: some View {
                HStack(alignment: .center, spacing: 8) {
                    Spacer()
                    if allowCLIMode {
                        FancyButtonv2(
                            text: "Command line mode",
                            action: {commandLineMode.toggle()},
                            icon: "apple.terminal",
                            iconWhenHighlighted: "apple.terminal.fill",
                            fgColour: self.state.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
                            showLabel: false,
                            size: .small,
                            type: .clear,
                            font: .title
                        )
                        .help("Enter CLI mode")
                        .frame(width: 25)
                    }

                    Widget.ResetUserChoices(onActionClear: self.onActionClear)

                    FancyButtonv2(
                        text: self.state.session.job != nil ? "Log to job \(self.state.session.job!.title ?? self.state.session.job!.jid.string)" : "Log",
                        action: self.onActionSubmit,
                        icon: "plus.square",
                        iconWhenHighlighted: "plus.square.fill",
                        fgColour: self.state.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
                        showLabel: false,
                        size: .small,
                        type: .clear,
                        font: .title
                    )
                    .help("Create a new record (alternatively, press Return!)")
                    .frame(width: 25)
                    .disabled(self.state.session.job == nil)
                    .opacity(self.state.session.job == nil ? 0.5 : 1)
                }
            }
        }
    }
}

extension Today.PostingInterface {
    /// Begin the process of creating new entities
    /// - Returns: Void
    private func submitAction() -> Void {
        if !text.isEmpty && nav.session.job != nil {
            Task {
                await self.save()
            }
        } else {
            if text.isEmpty {
                errorNoContent = true
            }
            
            if nav.session.job == nil {
                errorNoJob = true
            }
        }
    }
    
    /// Fires during the submitAction process. Creates new records & other entities.
    /// - Returns: Void
    private func save() async -> Void {
        if let job = nav.session.job {
            let record = LogRecord(context: moc)
            record.timestamp = Date()
            record.message = text
            record.alive = true
            record.id = UUID()
            record.job = job

            let matches = text.matches(of: /(.*) == (.*)/)
            if matches.count > 0 {
                for match in matches {
                    // Find existing term, if one exists
                    let name = String(match.1)
                    let definition = String(match.2)
                    let tTermDefinition = TaxonomyTermDefinitions(context: moc)
                    tTermDefinition.definition = definition
                    tTermDefinition.created = record.timestamp
                    tTermDefinition.job = job

                    // Add definition to existing term
                    if let foundTerm = CoreDataTaxonomyTerms(moc: self.moc).byName(name) {
                        foundTerm.addToDefinitions(tTermDefinition)
                    } else {
                        // For now, we create both records AND definitions
                        let term = TaxonomyTerm(context: moc)
                        term.name = name
                        term.created = record.timestamp
                        term.lastUpdate = record.timestamp
                        tTermDefinition.term = term
                    }
                }
            }

            do {
                try record.validateForInsert()

                PersistenceController.shared.save()
                nav.session.idate = DateHelper.identifiedDate(for: Date(), moc: moc)

                // Create a history item (used by CLI mode and, eventually, LogTable)
                if nav.session.cli.history.count <= CommandLineInterface.maxItems {
                    nav.session.cli.history.append(
                        Navigation.CommandLineSession.History(command: text, message: "", appType: .log, job: nav.session.job)
                    )
                }

                text = ""
            } catch {
                print("[error] Save error \(error)")
            }
        }
    }

    /// Clear the text field
    /// - Returns: Void
    private func clearAction() -> Void {
        self.text = ""
        self.nav.session.job = nil
        self.nav.session.company = nil
        self.nav.session.project = nil
    }
}
