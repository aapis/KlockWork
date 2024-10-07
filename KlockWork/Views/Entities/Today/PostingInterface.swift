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

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    FancyTextField(
                        placeholder: "What are you working on?",
                        lineLimit: 11,
                        onSubmit: submitAction,
                        fgColour: nav.session.job != nil ? nav.session.job!.colour_from_stored().isBright() ? .black : .white : .white,
                        text: $text
                    )
                    .background(nav.session.job != nil ? nav.session.job!.colour_from_stored() : .clear)
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

                    VStack(alignment: .trailing, spacing: 0) {
                        Spacer()
                        HStack(spacing: 1) {
                            Spacer()

                            if allowCLIMode {
                                FancyButtonv2(
                                    text: "Command line mode",
                                    action: {commandLineMode.toggle()},
                                    icon: "apple.terminal",
                                    fgColour: nav.session.job != nil ? Color.fromStored(nav.session.job!.colour!).isBright() ? Theme.base : .white : .white,
                                    showLabel: false,
                                    size: .tiny,
                                    type: .clear
                                )
                                .help("Enter CLI mode")
                                .frame(width: 30, height: 30)
                                .background(nav.session.job != nil ? nav.session.job!.colour_from_stored() : self.page.primaryColour.opacity(0.5))
                                .disabled(false)
                            }

                            FancyButtonv2(
                                text: "Reset interface to default state",
                                action: clearAction,
                                icon: "arrow.clockwise",
                                fgColour: nav.session.job != nil ? Color.fromStored(nav.session.job!.colour!).isBright() ? Theme.base : .white : .white,
                                showLabel: false,
                                size: .tiny,
                                type: .clear
                            )
                            .help("Reset interface to default state")
                            .frame(width: 30, height: 30)
                            .background(nav.session.job != nil ? nav.session.job!.colour_from_stored() : self.page.primaryColour.opacity(0.5))
                            .disabled(nav.session.job == nil)
                            .opacity(nav.session.job == nil ? 0.5 : 1)

                            FancyButtonv2(
                                text: nav.session.job != nil ? "Log to job \(nav.session.job!.jid.string)" : "Log",
                                action: submitAction,
                                icon: "plus",
                                fgColour: nav.session.job != nil ? Color.fromStored(nav.session.job!.colour!).isBright() ? Theme.base : .white : .white,
                                showLabel: false,
                                size: .tiny,
                                type: .clear
                            )
                            .help("Create a new record (alternatively, press Return!)")
                            .frame(width: 30, height: 30)
                            .background(nav.session.job != nil ? nav.session.job!.colour_from_stored() : self.page.primaryColour.opacity(0.5))
                            .disabled(nav.session.job == nil)
                            .opacity(nav.session.job == nil ? 0.5 : 1)
                        }
                        Divider().frame(height: 1).foregroundStyle(.clear)
                    }
                }
                .frame(height: 215)

                FancyHelpText(
                    text: "Choose a job from the sidebar, type into the field above. Enter/return/+ icon creates a new record in the table below.",
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
    }
}

extension Today.PostingInterface {
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

    private func clearAction() -> Void {
        text = ""
        nav.session.job = nil
    }
}
