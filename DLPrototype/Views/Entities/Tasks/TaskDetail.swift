//
//  TaskDetail.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-04.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskDetail: View {
    @EnvironmentObject public var state: Navigation
    @Environment(\.dismiss) private var dismiss
    @State public var task: LogTask?
    @State private var content: String = ""
    @State private var published: Bool = false
    @State private var isPresented: Bool = false
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .tasks

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Title(text: eType.enSingular, imageAsImage: eType.icon)
                FancyDivider()
                Toggle("Published", isOn: $published)
                FancyDivider()
                ZStack(alignment: .topTrailing) {
                    FancyTextField(
                        placeholder: "What needs to be done?",
                        lineLimit: 1,
                        onSubmit: self.actionOnSave,
                        disabled: self.state.session.job == nil,
                        text: $content
                    )

                    RowAddButton(
                        title: self.task != nil ? "Edit" : self.state.session.job != nil ? "Add" : "Save",
                        isPresented: $isPresented,
                        callback: self.actionOnSave
                    )
                        .frame(height: 45)
                        .disabled(self.content.isEmpty || self.state.session.job == nil)
                        .opacity(self.content.isEmpty || self.state.session.job == nil ? 0.5 : 1)
                }

                if self.state.session.job == nil {
                    FancyHelpText(
                        text: "Select a job first",
                        page: self.page
                    )
                }
            }
            .padding()
            Spacer()
        }
        .background(self.page.primaryColour)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.state.session.task) { self.actionOnAppear() }
        .onChange(of: self.published) { self.actionChangePublishStatus() }
    }
}

extension TaskDetail {
    /// Onload handler. Prepares view for deep link
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let stored = self.state.session.task {
            self.task = stored
            self.state.session.task = nil
        }

        self.content = self.task?.content ?? ""
        self.published = self.task?.cancelledDate == nil && self.task?.completedDate == nil
    }

    /// Fires when enter/return hit while entering text in field or when add button tapped
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.task != nil {
            self.task?.content = self.content

            if self.published == false {
                self.task?.cancelledDate = Date()
            }
        } else {
            CoreDataTasks(moc: self.state.moc).create(
                content: self.content,
                created: Date(),
                due: DateHelper.endOfTomorrow(Date()) ?? Date(),
                job: self.state.session.job
            )
        }

        self.content = ""

        PersistenceController.shared.save()
        self.dismiss()
        self.state.to(.tasks)
    }

    private func actionChangePublishStatus() -> Void {

    }
}
