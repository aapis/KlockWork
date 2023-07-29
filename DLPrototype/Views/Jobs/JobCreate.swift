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
    @State private var validUrl: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
//    @EnvironmentObject public var jm: CoreDataJob

    var body: some View {
        VStack(alignment: .leading) {

            VStack(alignment: .leading) {
                Title(text: "New job", image: "hammer")
                //                fieldProjectLink
                fieldIsOn
                fieldIsShredable

                FancyTextField(placeholder: "URL", lineLimit: 1, onSubmit: {}, showLabel: true, text: $url)
                    .background(validUrl ? Color.clear : Color.red)
                FancyTextField(placeholder: "Job ID", lineLimit: 1, onSubmit: {}, showLabel: true, text: $id)
                    .background(validJob ? Color.clear : Color.red)

                //                HStack {
                //                    FancyRandomJobColourPicker(job: job!, colour: $colour)
                //                    Spacer()
                //                }

                buttonSubmit
                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onChange(of: id) { jobId in
            let filtered = jobId.filter { "0123456789\\.".contains($0) }

            validJob = validateJob(filtered)
            id = filtered
        }
        .onChange(of: url) { newUrl in
            validUrl = validateUrl(newUrl)
        }
    }

    @ViewBuilder private var topSpace: some View {
        FancyDivider()
        Divider()
        FancyDivider()
    }

//    @ViewBuilder private var fieldProjectLink: some View {
//        if let project = job!.project {
//            FancyLink(
//                icon: "folder",
//                label: "Project: \(project.name!)",
//                showLabel: true,
//                colour: Color.fromStored(job!.project!.colour ?? Theme.rowColourAsDouble),
//                destination: AnyView(
//                    ProjectView(project: project)
//                        .environmentObject(jm)
//                ),
//                pageType: .projects
//            )
//        }
//    }

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
                text: "Create",
                action: update,
                size: .medium,
                redirect: AnyView(JobDashboard()),
                pageType: .jobs
            )
            .onAppear(perform: {print("DERPO viewload validJob:\(validJob) validUrl:\(validUrl)")})
                .keyboardShortcut("s")
                .disabled(validJob == true && validUrl == true ? false : true)
        }
    }

    private func update() -> Void {
        let job = Job(context: moc)
        if !url.isEmpty {
            job.uri = URL(string: url)!
        }

        if !id.isEmpty {
            job.jid = Double(id)!
        }

        job.alive = alive
        job.shredable = shredable

        PersistenceController.shared.save()
        updater.update()
    }

    private func validateJob(_ jobId: String) -> Bool {
        if jobId.isEmpty {
            return false
        }

        if let doubleId = Double(jobId) {
            if let _ = CoreDataJob(moc: moc).byId(doubleId) {
                return false
            }
        }

        return true
    }

    private func validateUrl(_ url: String) -> Bool {
        if url.isEmpty {
            return false
        }

        if url.starts(with: "https:") {
            if let uri = URL(string: url) {
                if let _ = CoreDataJob(moc: moc).byUrl(uri) {
                    return false
                }
            }
        } else {
            return false
        }

        return true
    }
}

struct JobCreate_Previews: PreviewProvider {
    static var previews: some View {
        JobCreate()
    }
}
