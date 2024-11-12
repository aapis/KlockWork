//
//  TermDetail.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-11-12.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct TermDetail: View {
    @EnvironmentObject public var state: Navigation
    @Environment(\.dismiss) private var dismiss
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .terms
    @State private var definitionString: String = ""
    @State private var alive: Bool = true
    @State private var name: String = ""
    @State private var term: TaxonomyTerm?
    @State private var isDeleteAlertPresented: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Title(text: "Term", image: "list.bullet.rectangle")
                Spacer()
                if self.term != nil {
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
            VStack(alignment: .leading, spacing: 0) {
                Toggle("Published", isOn: $alive)
                FancyDivider()
                FancyTextField(
                    placeholder: "A key, label, or name for an entity",
                    lineLimit: 1,
                    onSubmit: self.actionOnSave,
                    text: $name
                )
                .disabled(self.state.session.job == nil)
                .opacity(self.state.session.job == nil ? 0.5 : 1)

                if self.state.session.job == nil {
                    FancyHelpText(
                        text: "Select a job from the sidebar to get started.",
                        page: self.page
                    )
                }
            }
            Spacer()
        }
        .padding()
        .background(self.state.session.appPage.primaryColour)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.state.session.job) { self.actionOnAppear() }
    }
}

extension TermDetail {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let stored = self.state.session.term {
            self.term = stored
        }

        self.alive = self.term?.alive ?? false
        self.name = self.term?.name ?? ""
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
        if self.term != nil {
            self.term?.alive = self.alive
            self.term?.lastUpdate = Date()
            self.term?.name = self.name
        } else {
            CoreDataTaxonomyTerms(moc: self.state.moc).create(
                alive: true,
                name: self.name,
                saveByDefault: false
            )
        }

        PersistenceController.shared.save()
        self.state.to(.terms)
    }

    /// Fires when user chooses to unpublish a definition
    /// - Returns: Void
    private func actionOnSoftDelete() -> Void {
        self.alive = false
        self.term?.alive = false
        PersistenceController.shared.save()
        self.state.to(.terms)
    }
}
