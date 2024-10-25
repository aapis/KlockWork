//
//  TaskDetail.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-04.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct TaskDetail: View {
    @EnvironmentObject public var state: Navigation
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notifications.interval") private var notificationInterval: Int = 0
    @State public var task: LogTask?
    @State private var content: String = ""
    @State private var published: Bool = false
    @State private var isPresented: Bool = false
    @State private var shouldCreateNotification: Bool = true
    @State private var due: Date = DateHelper.endOfDay() ?? Date()
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .tasks
    @State private var isDisabled: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Title(text: eType.enSingular, imageAsImage: eType.icon)
                FancyDivider()
                Toggle("Published", isOn: $published)
                Toggle("Create notification", isOn: $shouldCreateNotification)
                FancyDivider()
                DatePicker("Due", selection: $due)
                HStack(alignment: .center) {
                    FancyButtonv2(text: "+1 Day", action: {self.due = DateHelper.startOfDay(self.due + 86400)}, showIcon: false, size: .tiny)
                        .frame(width: 70)
                    FancyButtonv2(text: "+1 Week", action: {self.due = DateHelper.startOfDay(self.due + (86400 * 7))}, showIcon: false, size: .tiny)
                        .frame(width: 70)
                    FancyButtonv2(text: "+1 Month", action: {self.due = DateHelper.startOfDay(self.due + (86400 * 31))}, showIcon: false, size: .tiny)
                            .frame(width: 80)
                }
                .frame(height: 30)
                FancyDivider()
                ZStack(alignment: .topTrailing) {
                    FancyTextField(
                        placeholder: "What needs to be done?",
                        lineLimit: 1,
                        onSubmit: self.actionOnSave,
                        disabled: self.isDisabled,
                        text: $content
                    )

                    RowAddButton(
                        title: self.task != nil ? "Save" : self.state.session.job != nil ? "Add" : "Save",
                        isPresented: $isPresented,
                        callback: self.actionOnSave
                    )
                        .frame(height: 45)
                        .disabled(self.content.isEmpty || self.isDisabled)
                        .opacity(self.content.isEmpty || self.isDisabled ? 0.5 : 1)
                }

                if self.isDisabled {
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
        self.due = self.task?.due ?? DateHelper.endOfDay() ?? Date()
        self.shouldCreateNotification = !(self.task?.hasScheduledNotification ?? false)
        self.isDisabled = self.state.session.job == nil && self.task == nil
    }

    /// Fires when enter/return hit while entering text in field or when add button tapped
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.task != nil {
            self.task?.content = self.content
            self.task?.due = self.due
            if self.published == false {
                self.task?.cancelledDate = Date()
            }
            self.task?.lastUpdate = Date()
        } else {
            self.task = CoreDataTasks(moc: self.state.moc).createAndReturn(
                content: self.content,
                created: Date(),
                due: DateHelper.endOfDay(Date()) ?? Date(),
                job: self.state.session.job
            )
        }

        if self.shouldCreateNotification && self.task != nil {
            NotificationHelper.createInterval(interval: self.notificationInterval, task: self.task!)
        }

        self.content = ""
        PersistenceController.shared.save()
        self.dismiss()
        self.state.to(.tasks)
    }

    private func actionChangePublishStatus() -> Void {

    }
}
