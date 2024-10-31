//
//  JobView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

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
                .background(validUrl ? .clear : .red) // @TODO: remove, this looks terrible
            FancyTextField(placeholder: "Job ID", lineLimit: 1, onSubmit: {}, showLabel: true, text: $id)
                .background(validJob ? .clear : .red) // @TODO: remove, this looks terrible
            FancyJobActiveToggle(entity: job)
                .background(job.alive ? .green : .clear) // @TODO: remove, this looks terrible
            FancyJobSredToggle(entity: job)
                .background(job.shredable ? .green : .clear) // @TODO: remove, this looks terrible
            FancyColourPicker(initialColour: job.colour ?? Theme.rowColourAsDouble, onChange: {newColour in colour = newColour})
            Spacer()
            buttonSubmit
        }
        .padding(5)
        .onAppear(perform: setEditableValues)
        .onChange(of: nav.session.job) {
            setEditableValues()
        }
        .onChange(of: id) {
            JobFormValidator(moc: moc).onChangeCallback(
                jobFieldValue: self.id,
                valid: $validJob,
                id: $id
            )

            if validJob {
                job.jid = Double(self.id) ?? 0.0
                PersistenceController.shared.save()
            }
        }
        .onChange(of: url) {
            JobFormValidator(moc: moc).onChangeCallback(
                urlFieldValue: self.url,
                valid: $validUrl,
                id: $id
            )

            if validUrl {
                job.uri = URL(string: self.url)
                PersistenceController.shared.save()
            }
        }
        .onChange(of: self.alive) {
            job.alive = self.alive
            PersistenceController.shared.save()
        }
        .onChange(of: self.nav.saved) {
            if self.nav.saved {
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

        self.nav.to(.jobs)
    }
    
    private func actionClearProject() -> Void {
        if let project = job.project {
            project.removeFromJobs(job)
            PersistenceController.shared.save()
        }
    }
}
