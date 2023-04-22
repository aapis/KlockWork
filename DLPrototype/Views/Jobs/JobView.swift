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
    @Binding public var job: Job?
    
    @State private var id: String = ""
    @State private var pName: String = ""
    @State private var pId: String = ""
    @State private var url: String = ""
    @State private var colour: String = ""
    @State private var alive: Bool = true
    
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var jm: CoreDataJob
    
    var body: some View {
        VStack(alignment: .leading) {
            FancyDivider()
            Divider()
            FancyDivider()
            
            if job != nil {
                if job!.project != nil {
                    FancyLink(
                        icon: "folder",
                        label: "Project: \(job!.project!.name!)",
                        showLabel: true,
                        colour: Color.fromStored(job!.project!.colour ?? Theme.rowColourAsDouble),
                        destination: AnyView(
                            ProjectView(project: job!.project!)
                                .environmentObject(jm)
                        )
                    )
                }
            }

            FancyDivider()
            
            HStack {
                Toggle("Job is active", isOn: $alive)
                    .onAppear(perform: {
                        if job != nil {
                            if job!.alive {
                                alive = true
                            } else {
                                alive = false
                            }
                            
                            update()
                        }
                    })
                Spacer()
            }
            
            FancyTextField(placeholder: "Job ID", lineLimit: 1, onSubmit: {}, showLabel: true, text: $id)
            FancyTextField(placeholder: "URL", lineLimit: 1, onSubmit: {}, showLabel: true, text: $url)
            
            if job != nil {
                HStack {
                    FancyRandomJobColourPicker(job: job!, colour: $colour)
                    Spacer()
                }
            }
            
            HStack {
                Spacer()
                FancyButton(text: "Update", action: update)
                    .keyboardShortcut("s")
            }
        }
        .onAppear(perform: setEditableValues)
        .onChange(of: job) { _ in
            setEditableValues()
        }
    }
    
    private func setEditableValues() -> Void {
        if job != nil {
            id = job!.jid.string
            if job!.project != nil {
                pName = job!.project!.name!
                pId = String(job!.project!.pid)
            }
            
            if job!.uri != nil {
                url = job!.uri!.description
            } else {
                url = ""
            }
        }
    }
    
    private func update() -> Void {
        if job != nil {
            if !url.isEmpty {
                job!.uri = URL(string: url)!
            }
            
            if !id.isEmpty {
                job!.jid = Double(id)!
            }
            
            job?.alive = alive
            
            PersistenceController.shared.save()
            updater.update()
        }
    }
}
