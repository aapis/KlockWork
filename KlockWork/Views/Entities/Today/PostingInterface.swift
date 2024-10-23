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
        @EnvironmentObject public var nav: Navigation
        @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false
        @AppStorage("general.experimental.cli") private var allowCLIMode: Bool = false
        @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
        @FocusState private var primaryTextFieldInFocus: Bool
        @State private var text: String = ""
        @State private var errorNoJob: Bool = false
        @State private var errorNoContent: Bool = false
        private let page: PageConfiguration.AppPage = .today
        private let eType: PageConfiguration.EntityType = .records

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                UniversalHeader.Widget(
                    type: self.eType
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
            .onAppear(perform: self.setFieldFocus)
            .onChange(of: self.isSearchStackShowing) { self.setFieldFocus() }
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
            let record = LogRecord(context: self.nav.moc)
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
                    let tTermDefinition = TaxonomyTermDefinitions(context: self.nav.moc)
                    tTermDefinition.definition = definition
                    tTermDefinition.created = record.timestamp
                    tTermDefinition.job = job

                    // Add definition to existing term
                    if let foundTerm = CoreDataTaxonomyTerms(moc: self.nav.moc).byName(name) {
                        foundTerm.addToDefinitions(tTermDefinition)
                    } else {
                        // For now, we create both records AND definitions
                        let term = TaxonomyTerm(context: self.nav.moc)
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
                nav.session.idate = DateHelper.identifiedDate(for: Date(), moc: self.nav.moc)

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
    
    /// Onload handler. Sets whether field is focused or not.
    /// - Returns: Void
    private func setFieldFocus() -> Void {
        self.primaryTextFieldInFocus = !self.isSearchStackShowing
    }
}
