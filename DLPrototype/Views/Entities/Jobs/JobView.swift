//
//  JobView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct JobView: View {
    public var job: Job
    
    @State private var id: String = ""
    @State private var pName: String = ""
    @State private var pId: String = ""
    @State private var url: String = ""
    @State private var colour: Color = .clear
    @State private var alive: Bool = true
    @State private var shredable: Bool = false
    @State private var validJob: Bool = false
    @State private var validUrl: Bool = false
    @State private var isDeleteAlertShowing: Bool = false
    @State private var projectPickerDisplayName: String = "Hello"

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater

    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            fieldProjectLink

            FancyTextField(placeholder: "URL", lineLimit: 1, onSubmit: {}, showLabel: true, text: $url)
                .background(validUrl ? .clear : .red)
            FancyTextField(placeholder: "Job ID", lineLimit: 1, onSubmit: {}, showLabel: true, text: $id)
                .background(validJob ? .clear : .red)
            FancyJobActiveToggle(entity: job)
                .background(job.alive ? .green : .clear)
            FancyJobSredToggle(entity: job)
                .background(job.shredable ? .green : .clear)
            FancyColourPicker(initialColour: job.colour ?? Theme.rowColourAsDouble, onChange: {newColour in colour = newColour})
            Spacer()
            buttonSubmit
        }
        .padding(5)
        .onAppear(perform: setEditableValues)
        .onChange(of: nav.session.job) { _ in
            setEditableValues()
        }
        .onChange(of: id) { jobId in
            JobFormValidator(moc: moc).onChangeCallback(
                jobFieldValue: jobId,
                valid: $validJob,
                id: $id
            )

            if validJob {
                job.jid = Double(jobId) ?? 0.0
                PersistenceController.shared.save()
            }
        }
        .onChange(of: url) { newUrl in
            JobFormValidator(moc: moc).onChangeCallback(
                urlFieldValue: newUrl,
                valid: $validUrl,
                id: $id
            )

            if validUrl {
                job.uri = URL(string: newUrl)
                PersistenceController.shared.save()
            }
        }
        .onChange(of: alive) { status in
            job.alive = status
            PersistenceController.shared.save()
        }
        .onChange(of: nav.saved) { status in
            if status {
                self.update()
            }
        }
    }

    @ViewBuilder private var fieldProjectLink: some View {
        if let project = job.project {
            HStack {
                FancyLabel(text: "Project")
                FancyLink(
                    icon: "folder",
                    label: project.name!,
                    showLabel: true,
                    colour: Color.fromStored(job.project!.colour ?? Theme.rowColourAsDouble),
                    destination: AnyView(ProjectView(project: project)),
                    pageType: .projects,
                    sidebar: AnyView(ProjectsDashboardSidebar())
                )
                FancySimpleButton(
                    text: project.name!,
                    action: actionClearProject,
                    icon: "xmark",
                    showLabel: false,
                    showIcon: true
                )
            }
        } else {
            ProjectPickerUsing(onChange: {_, _ in}, displayName: $projectPickerDisplayName)
        }
    }

    @ViewBuilder private var buttonSubmit: some View {
        ZStack {
            HStack {
                FancyButtonv2(
                    text: "Delete",
                    action: {isDeleteAlertShowing = true},
                    icon: "trash",
                    showLabel: false,
                    type: .destructive
                )
                .alert("Are you sure you want to delete job ID \(job.jid.string)?", isPresented: $isDeleteAlertShowing) {
                    Button("Yes", role: .destructive) {
                        hardDelete()
                    }
                    Button("No", role: .cancel) {}
                }

                Spacer()
                FancyButtonv2(
                    text: "Update",
                    action: update,
                    size: .medium,
                    type: .primary
                )
                .keyboardShortcut("s", modifiers: .command)
            }
        }
    }
}

extension JobView {
    private func setEditableValues() -> Void {
        if let job = nav.session.job {
            id = job.jid.string
            if job.project != nil {
                pName = job.project!.name!
                pId = String(job.project!.pid)
            }

            if job.uri != nil {
                url = job.uri!.description
            } else {
                url = ""
            }
        } else {
            id = job.jid.string
            if job.project != nil {
                pName = job.project!.name!
                pId = String(job.project!.pid)
            }

            if job.uri != nil {
                url = job.uri!.description
            } else {
                url = ""
            }
        }
    }
    
    private func update() -> Void {
        if !url.isEmpty {
            job.uri = URL(string: url)!
        }

        if !id.isEmpty {
            job.jid = Double(id)!
        }

        if job.id == nil {
            job.id = UUID()
        }

        job.alive = alive
        job.shredable = shredable

        PersistenceController.shared.save()
        updater.update()
        nav.save()
    }

    private func softDelete() -> Void {
        job.alive = false
        PersistenceController.shared.save()
        updater.update()
    }

    private func hardDelete() -> Void {
        moc.delete(job)
        PersistenceController.shared.save()

        nav.setView(AnyView(JobDashboard()))
        nav.setId()
        nav.setParent(.jobs)
        nav.setSidebar(AnyView(JobDashboardSidebar()))
    }
    
    private func actionClearProject() -> Void {
        if let project = job.project {
            project.removeFromJobs(job)
            PersistenceController.shared.save()
        }
    }
}
