//
//  PeopleDetail.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-03.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct PeopleDetail: View {
    @EnvironmentObject public var state: Navigation
    @Environment(\.dismiss) private var dismiss
    @State public var person: Person?
    @State private var isDeleteAlertPresented: Bool = false
    @State private var name: String = ""
    @State private var title: String = ""
    @State private var company: Company?
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .people

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Title(text: self.eType.label, imageAsImage: self.eType.icon)
                Spacer()

                if self.person != nil {
                    FancyButtonv2(
                        text: "Delete",
                        action: {isDeleteAlertPresented = true},
                        icon: "trash",
                        showLabel: false,
                        type: .destructive
                    )
                    .alert("Are you sure you want to delete this contact?", isPresented: $isDeleteAlertPresented) {
                        Button("Yes", role: .destructive) {
                            self.actionOnDelete()
                        }
                        Button("No", role: .cancel) {}
                    }
                    .disabled(self.company == nil)
                    .opacity(self.company == nil ? 0.5 : 1)
                }

                FancyButtonv2(text: "Cancel", action: self.actionOnCancel, showIcon: false)
                    .disabled(self.company == nil)
                    .opacity(self.company == nil ? 0.5 : 1)
                FancyButtonv2(text: "Save", action: self.actionOnSave, showIcon: false, type: .primary)
                    .disabled(self.company == nil)
                    .opacity(self.company == nil ? 0.5 : 1)
            }
            .padding(.bottom)

            VStack(alignment: .leading) {
                FancyTextField(
                    placeholder: "Name",
                    onSubmit: self.actionOnSave,
                    text: $name
                )
                .disabled(self.company == nil).onChange(of: self.state.session.task) { self.actionOnAppear() }
                .opacity(self.company == nil ? 0.5 : 1)
                FancyTextField(
                    placeholder: "Title",
                    onSubmit: self.actionOnSave,
                    text: $title
                )
                .disabled(self.company == nil)
                .opacity(self.company == nil ? 0.5 : 1)

                if self.company == nil {
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
        .onChange(of: self.state.session.person) { self.actionOnAppear() }
        .onChange(of: self.state.session.job) { self.actionOnAppear() }
    }
}

extension PeopleDetail {
    private func actionOnAppear() -> Void {
        if let stored = self.state.session.person {
            self.person = stored
            self.state.session.person = nil
        }

        self.name = self.person?.name ?? ""
        self.title = self.person?.title ?? ""

        if let stored = self.state.session.company {
            self.company = stored
        } else if let stored = self.state.session.job {
            self.company = stored.project?.company
        }
    }

    /// Callback that fires when save button clicked/tapped
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.person != nil {
            self.person?.name = self.name
            self.person?.title = self.title
            self.person?.company = self.company
        } else {
            let date = Date()
            CoreDataPerson(moc: self.state.moc).create(
                created: date,
                lastUpdate: date,
                name: self.name,
                title: self.title,
                company: self.person?.company
            )
        }

        PersistenceController.shared.save()
        self.state.to(.people)
        self.dismiss()
    }

    /// Fires when user chooses to unpublish a definition
    /// - Returns: Void
    private func actionOnDelete() -> Void {
        if self.person != nil {
            self.state.moc.delete(self.person!)
            PersistenceController.shared.save()
            self.dismiss()
        }
    }

    /// Callback that fires when cancel button clicked/tapped
    /// - Returns: Void
    private func actionOnCancel() -> Void {
        self.state.to(.people)
        self.dismiss()
    }
}
