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
                ZStack(alignment: .leading) {
                    TypedListRowBackground(colour: self.nav.session.job?.backgroundColor ?? Theme.rowColour, type: .jobs)
                        .frame(height: 60)
                        .clipShape(.rect(topLeadingRadius: 5, topTrailingRadius: 5))
                    ResourcePath()
                }

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

    struct ResourcePath: View {
        @EnvironmentObject public var state: Navigation
        @State private var resourcePath: String = ""
        @State private var parts: [ResourcePathItem] = []

        var body: some View {
            HStack(alignment: .center, spacing: 8) {
                if self.parts.count > 0 {
                    ForEach(self.parts, id: \.id) { part in part }
                } else {
                    ResourcePathItem(text: "Choose a job from the sidebar, type into the field below. Enter/Return/+ to create records.")
                }
            }
            .padding([.leading, .trailing])
            .font(.title2)
            .foregroundStyle((self.state.session.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base.opacity(0.55) : .white.opacity(0.55))
            .onAppear(perform: self.actionSetViewState)
            .onChange(of: self.state.session.job) { self.actionSetViewState() }
            .onChange(of: self.state.session.project) { self.actionSetViewState() }
            .onChange(of: self.state.session.company) { self.actionSetViewState() }
        }

        struct ResourcePathItem: View, Identifiable {
            @EnvironmentObject public var state: Navigation
            public var id: UUID = UUID()
            public var text: String
            public var target: Page = .dashboard
            @State private var isHighlighted: Bool = false

            var body: some View {
                HStack(alignment: .center) {
                    Button {
                        self.state.to(self.target)
                    } label: {
                        Text(self.text)
                            .underline(self.isHighlighted && self.target != .dashboard) // using .dashboard as "default"
                    }
                    .buttonStyle(.plain)

                    if self.text != self.state.session.job?.title && self.target != .dashboard {
                        Image(systemName: "chevron.right")
                    }
                }
                .useDefaultHover({ hover in self.isHighlighted = hover})
            }
        }
    }
}

extension Today.ResourcePath {
    /// Fires onload and whenever the session job is changed. Compiles a breadcrumb based on selected job/project/company
    /// - Returns: Void
    private func actionSetViewState() -> Void {
        self.parts = []
        if let company = self.state.session.company {
            if company.name != nil {
                self.parts.append(ResourcePathItem(text: company.name!, target: company.pageDetailType))
            }
        }

        if let project = self.state.session.project {
            if project.name != nil {
                self.parts.append(ResourcePathItem(text: project.name!, target: project.pageDetailType))
            }
        }

        if let job = self.state.session.job {
            self.parts.append(ResourcePathItem(text: job.title ?? job.jid.string, target: job.pageDetailType))
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
