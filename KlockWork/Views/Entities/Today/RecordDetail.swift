//
//  RecordDetail.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-11.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct RecordDetail: View {
    @EnvironmentObject public var state: Navigation
    @Environment(\.dismiss) private var dismiss
    @State public var record: LogRecord?
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .records
    @State private var message: String = ""
    @State private var alive: Bool = true
    @State private var job: Job?
    @State private var isDeleteAlertPresented: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Title(text: self.eType.enSingular, imageAsImage: self.eType.icon)
                Spacer()

                if self.record != nil {
                    FancyButtonv2(
                        text: "Delete",
                        action: {isDeleteAlertPresented = true},
                        icon: "trash",
                        showLabel: false,
                        type: .destructive
                    )
                    .alert("Are you sure you want to delete this record?", isPresented: $isDeleteAlertPresented) {
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

                FancyTextField(
                    placeholder: "Message",
                    lineLimit: 11,
                    onSubmit: self.actionOnSave,
                    text: $message
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
        .background(self.page.primaryColour)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.state.session.record) { self.actionOnAppear() }
        .onChange(of: self.state.session.job) { self.job = self.state.session.job }
    }
}

extension RecordDetail {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let stored = self.state.session.record {
            self.record = stored
            self.state.session.record = nil
        }

        self.message = self.record?.message ?? ""
        self.alive = self.record?.alive ?? false
        self.job = self.record?.job
    }

    /// Callback that fires when cancel button clicked/tapped
    /// - Returns: Void
    private func actionOnCancel() -> Void {
        self.state.to(.today)
        self.dismiss()
    }

    /// Callback that fires when save button clicked/tapped
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.record != nil {
            self.record?.message = self.message
            self.record?.alive = self.alive
            self.record?.job = self.state.session.job
        } else {
            if let job = self.job {
                CoreDataRecords(moc: self.state.moc).createWithJob(
                    job: job,
                    date: self.state.session.date,
                    text: self.message
                )
            }
        }

        PersistenceController.shared.save()
        self.state.to(.today)
    }

    /// Fires when user chooses to unpublish a definition
    /// - Returns: Void
    private func actionOnSoftDelete() -> Void {
        self.alive = false
        self.record?.alive = false
        PersistenceController.shared.save()
        self.state.to(.today)
    }
}
