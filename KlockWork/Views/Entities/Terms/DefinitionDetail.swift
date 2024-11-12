//
//  DefinitionDetail.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-01.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct DefinitionDetail: View {
    @EnvironmentObject public var state: Navigation
    @Environment(\.dismiss) private var dismiss
    @State public var definition: TaxonomyTermDefinitions?
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .terms
    @State private var definitionString: String = ""
    @State private var alive: Bool = true
    @State private var term: TaxonomyTerm?
    @State private var isDeleteAlertPresented: Bool = false
    // @TODO: not sure if I want this here
//    @FocusState private var primaryTextFieldInFocus: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Title(text: "Definition", image: "list.bullet.rectangle")
                Spacer()
                if self.definition != nil {
                    FancyButtonv2(
                        text: "Delete",
                        action: {isDeleteAlertPresented = true},
                        icon: "trash",
                        showLabel: false,
                        type: .destructive
                    )
                    .alert("Are you sure you want to delete this term?", isPresented: $isDeleteAlertPresented) {
                        Button("Yes", role: .destructive) {
                            self.actionOnSoftDelete()
                        }
                        Button("No", role: .cancel) {}
                    }
                    .disabled(self.state.session.job == nil)
                    .opacity(self.state.session.job == nil ? 0.5 : 1)
                }

                FancyButtonv2(text: "Cancel", action: self.actionOnCancel, showIcon: false)
                    .disabled(self.state.session.job == nil)
                    .opacity(self.state.session.job == nil ? 0.5 : 1)
                FancyButtonv2(text: "Save", action: self.actionOnSave, showIcon: false, type: .primary)
                    .disabled(self.state.session.job == nil)
                    .opacity(self.state.session.job == nil ? 0.5 : 1)
            }
            .padding(.bottom)

            VStack(alignment: .leading, spacing: 0) {
                Toggle("Published", isOn: $alive)
                FancyDivider()
                FancyTextField(
                    placeholder: "A statement of the meaning of a word, phrase, or term, as in a dictionary entry.",
                    lineLimit: 11,
                    onSubmit: self.actionOnSave,
                    text: $definitionString
                )
                .disabled(self.state.session.job == nil)
                .opacity(self.state.session.job == nil ? 0.5 : 1)

                if self.state.session.job == nil {
                    FancyHelpText(
                        text: "Select a job from the sidebar to get started.",
                        page: self.page
                    )
                }
                // @TODO: not sure if I want this here
//                .focused($primaryTextFieldInFocus)
//                .onAppear {
//                    // thx https://www.kodeco.com/31569019-focus-management-in-swiftui-getting-started#toc-anchor-002
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.primaryTextFieldInFocus = true
//                    }
//                }
            }

            Spacer()
        }
        .padding()
        .background(self.page.primaryColour)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.state.session.definition) { self.actionOnAppear() }
    }
}

extension DefinitionDetail {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let stored = self.state.session.definition {
            self.definition = stored
            self.state.session.definition = nil
        }

        self.definitionString = self.definition?.definition ?? ""
        self.alive = self.definition?.alive ?? true
        self.term = self.definition?.term
    }

    /// Callback that fires when cancel button clicked/tapped
    /// - Returns: Void
    private func actionOnCancel() -> Void {
        self.state.to(.terms)
        self.dismiss()
    }

    /// Callback that fires when save button clicked/tapped
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.definition != nil {
            self.definition?.definition = self.definitionString
            self.definition?.alive = self.alive
            self.definition?.job = self.state.session.job
            self.definition?.term = self.term
        } else {
            CoreDataTaxonomyTermDefinitions(moc: self.state.moc).create(
                alive: self.alive,
                created: Date(),
                definition: self.definitionString,
                lastUpdate: Date(),
                job: self.state.session.job,
                term: self.term // @TODO: NOTE TO SELF: all new items created will not be associated with terms until we build a term selector
            )
        }

        PersistenceController.shared.save()
        self.state.to(.terms)
    }
    
    /// Fires when user chooses to unpublish a definition
    /// - Returns: Void
    private func actionOnSoftDelete() -> Void {
        self.alive = false
        self.definition?.alive = false
        PersistenceController.shared.save()
        self.state.to(.terms)
    }
}
