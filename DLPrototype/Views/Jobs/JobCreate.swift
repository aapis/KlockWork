//
//  JobCreate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-28.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobCreate: View {
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

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
//    @EnvironmentObject public var jm: CoreDataJob

    var body: some View {
        VStack(alignment: .leading) {

            VStack(alignment: .leading) {
                Title(text: "New job")

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
        .background(Theme.toolbarColour)
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
                action: {},
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
                type: .primary,
//                redirect: AnyView(JobView(job: $job)), // this works but the view page isn't styled properly yet
                redirect: AnyView(JobDashboard()),
                pageType: .jobs
            )
                .keyboardShortcut("s")
                .disabled(
                    validJob == true && validUrl == true && validColour == true && validProject == true ? false : true
                )
        }
    }

    private func update() -> Void {
        let newJob = Job(context: moc)
        if !url.isEmpty {
            newJob.uri = URL(string: url)!
        }

        if !id.isEmpty {
            newJob.jid = Double(id)!
        }

        newJob.project = project!
        newJob.alive = alive
        newJob.shredable = shredable
        newJob.colour = colourAsDouble

        job = newJob

        PersistenceController.shared.save()
        updater.update()
    }

    private func colourPickerChange(colour: [Double]) -> Void {
        colourAsDouble = colour
        validColour = true
    }

    private func projectPickerChange(selected: String, sender: String?) -> Void {
        if !selected.isEmpty {
            if let match = CoreDataProjects(moc: moc).byName(selected) {
                project = match
                validProject = true
            }
        }
    }
}

struct JobCreate_Previews: PreviewProvider {
    static var previews: some View {
        JobCreate()
    }
}
