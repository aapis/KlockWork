//
//  JobCreate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-28.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobCreate: View {
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
    @Environment(\.dismiss) private var dismiss
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .jobs
    @State private var id: String = ""
    @State private var pName: String = ""
    @State private var pId: String = ""
    @State private var url: String = ""
    @State private var colour: String = ""
    @State private var alive: Bool = true
    @State private var shredable: Bool = false
    @State private var validJob: Bool = false
    @State private var validUrl: Bool = true
    @State private var validProject: Bool = false
    @State private var validColour: Bool = false
    @State private var colourAsDouble: [Double] = []
    @State private var project: Project?
    @State private var job: Job?

    var body: some View {
        VStack(alignment: .leading) {

            VStack(alignment: .leading) {
                Title(text: "Create Job", imageAsImage: self.eType.icon)

                fieldProjectLink
                fieldIsOn
                fieldIsShredable

                FancyTextField(placeholder: "URL", lineLimit: 1, onSubmit: {}, showLabel: true, text: $url)
                    .background(validUrl ? Color.clear : Color.red)
                FancyTextField(placeholder: "Job ID", lineLimit: 1, onSubmit: {}, showLabel: true, text: $id)
                    .background(validJob ? Color.clear : Color.red)
                FancyRandomJobColourPicker(colour: $colour, onChange: colourPickerChange)
                buttonSubmit
                Spacer()
            }
            .padding()
        }
        .background(self.page.primaryColour)
        .onChange(of: id) {
            JobFormValidator(moc: self.nav.moc).onChangeCallback(
                jobFieldValue: id,
                valid: $validJob,
                id: $id
            )
        }
        .onChange(of: url) {
            JobFormValidator(moc: self.nav.moc).onChangeCallback(
                urlFieldValue: url,
                valid: $validUrl,
                id: $id
            )
        }
    }

    @ViewBuilder private var topSpace: some View {
        FancyDivider()
        Divider()
        FancyDivider()
    }

    @ViewBuilder private var fieldProjectLink: some View {
        ProjectPickerUsing(onChange: projectPickerChange, displayName: $pName)
    }

    @ViewBuilder private var fieldIsOn: some View {
        FancyDivider()

        HStack {
            Toggle("Job is active", isOn: $alive)
            Spacer()
        }
    }

    @ViewBuilder private var fieldIsShredable: some View {
        HStack {
            Toggle("Eligible for SR&ED", isOn: $shredable)
            Spacer()
        }
    }

    @ViewBuilder private var buttonSubmit: some View {
        HStack {
            Spacer()
            FancyButtonv2(
                text: "Cancel",
                action: {self.dismiss()},
                icon: "xmark",
                showLabel: false,
                redirect: AnyView(JobDashboard()),
                pageType: .jobs,
                sidebar: AnyView(JobDashboardSidebar())
            )
            FancyButtonv2(
                text: "Create",
                action: update,
                size: .medium,
                type: .primary
//                redirect: AnyView(JobView(job: $job)), // this works but the view page isn't styled properly yet
//                redirect: AnyView(ProjectsDashboard()),
//                pageType: .jobs,
//                sidebar: AnyView(JobDashboardSidebar())
            )
                .keyboardShortcut("s")
                .disabled(
                    validJob == true && validUrl == true && validColour == true && validProject == true ? false : true
                )
        }
    }
}

extension JobCreate {
    private func update() -> Void {
        let newJob = Job(context: self.nav.moc)
        if validUrl && !url.isEmpty {
            newJob.uri = URL(string: url)!
        }

        if !id.isEmpty {
            newJob.jid = Double(id)!
        }

        newJob.id = UUID()
        newJob.alive = alive
        newJob.shredable = shredable
        newJob.colour = colourAsDouble
        newJob.created = Date()
        newJob.lastUpdate = newJob.created
        job = newJob

        if validProject {
            if let proj = project {
                proj.addToJobs(newJob)
                newJob.project = proj

                nav.setView(AnyView(JobDashboard()))
                nav.setId()
                nav.setParent(.jobs)
                nav.setSidebar(AnyView(JobDashboardSidebar()))
            }
        }

        PersistenceController.shared.save()
        nav.session.job = job
    }

    private func colourPickerChange(colour: [Double]) -> Void {
        colourAsDouble = colour
        validColour = true
    }

    private func projectPickerChange(selected: String, sender: String?) -> Void {
        if !selected.isEmpty {
            if let match = CoreDataProjects(moc: self.nav.moc).byName(selected) {
                project = match
                validProject = true
            }
        }
    }
}
