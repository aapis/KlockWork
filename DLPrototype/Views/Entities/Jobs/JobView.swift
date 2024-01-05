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

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
    
    var body: some View {
        VStack(alignment: .leading) {
            topSpace

            fieldProjectLink

            FancyTextField(placeholder: "URL", lineLimit: 1, onSubmit: {}, showLabel: true, text: $url)
                .background(validUrl ? Color.clear : Color.red)
            FancyTextField(placeholder: "Job ID", lineLimit: 1, onSubmit: {}, showLabel: true, text: $id)
                .background(validJob ? Color.clear : Color.red)
            FancyJobActiveToggle(entity: job)
            FancyJobSredToggle(entity: job)
            FancyColourPicker(initialColour: job.colour ?? Theme.rowColourAsDouble, onChange: {newColour in colour = newColour})
            Spacer()
            buttonSubmit
        }
        .onAppear(perform: setEditableValues)
        .onChange(of: job) { _ in
            setEditableValues()
        }
        .onChange(of: id) { jobId in
            JobFormValidator(moc: moc).onChangeCallback(
                jobFieldValue: jobId,
                valid: $validJob,
                id: $id
            )
        }
        .onChange(of: url) { newUrl in
            JobFormValidator(moc: moc).onChangeCallback(
                urlFieldValue: newUrl,
                valid: $validUrl,
                id: $id
            )
        }
    }
    
    @ViewBuilder private var topSpace: some View {
        FancyDivider()
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
            }
        }
    }

    @ViewBuilder private var buttonSubmit: some View {
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
                type: .primary,
                redirect: AnyView(JobDashboard()),
                pageType: .jobs,
                sidebar: AnyView(JobDashboardSidebar())
            )
            .keyboardShortcut("s", modifiers: .command)
        }
    }
    
    private func setEditableValues() -> Void {
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
}
