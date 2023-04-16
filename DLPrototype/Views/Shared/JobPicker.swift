//
//  JobPicker.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct JobPicker: View {
    public var onChange: (Int, String?) -> Void
    public var transparent: Bool? = false
    public var labelText: String?
    public var showLabel: Bool? = false
    
    @State private var jobId: String = ""
    @State private var jobIdFieldColour: Color = Color.clear
    @State private var jobIdFieldTextColour: Color = Color.white
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var jm: CoreDataJob
    
    private var pickerItems: [CustomPickerItem] {
        var items: [CustomPickerItem] = [CustomPickerItem(title: "Choose a job", tag: 0)]
        let projects = CoreDataProjects(moc: moc).alive()
        
        for project in projects {
            if project.jobs!.count > 0 {
                items.append(CustomPickerItem(title: "Project: \(project.name!)", tag: Int(-1)))
                
                if project.jobs != nil {
                    let unsorted = project.jobs!.allObjects as! [Job]
                    var jobs = unsorted.sorted(by: ({$0.jid > $1.jid}))
                    jobs.removeAll(where: {($0.project?.configuration?.ignoredJobs!.contains($0.jid.string))!})                    
                    
                    for job in jobs {
                        items.append(CustomPickerItem(title: " - \(job.jid.string)", tag: Int(job.jid)))
                    }
                }
            }
        }
        
        return items
    }
    
    var body: some View {
        HStack {
            ZStack {
                FancyTextField(
                    placeholder: "Job ID",
                    lineLimit: 1,
                    onSubmit: {},
                    fgColour: jobIdFieldTextColour,
                    bgColour: jobIdFieldColour,
                    text: $jobId
                )
                .border(jobIdFieldColour == Color.clear ? Color.black.opacity(0.1) : Color.clear, width: 2)
                .onChange(of: jobId) { _ in
                    if jobId != "" {
                        if let iJid = Int(jobId) {
                            pickerChange(selected: iJid, sender: nil)
                        }
                    }
                }
                HStack {
                    if !jobId.isEmpty {
                        FancyButton(text: "Reset", action: resetJobUi, icon: "xmark", showLabel: false)
                    }
                    FancyPicker(onChange: pickerChange, items: pickerItems, transparent: transparent, labelText: labelText, showLabel: showLabel)
                }
                .padding([.leading], 100)
            }
        }
        .frame(width: 350, height: 40)
    }
    
    private func pickerChange(selected: Int, sender: String?) -> Void {
        jobId = String(selected)
        
        if let selectedJob = jm.byId(Double(jobId)!) {
            jobIdFieldColour = Color.fromStored(selectedJob.colour ?? Theme.rowColourAsDouble)
            jobIdFieldTextColour = jobIdFieldColour.isBright() ? Color.black : Color.white
        } else {
            jobIdFieldColour = Color.clear
            jobIdFieldTextColour = Color.white
        }
        
        onChange(selected, sender)
    }
    
    private func resetJobUi() -> Void {
        jobId = ""
        jobIdFieldColour = Color.clear
        jobIdFieldTextColour = Color.white
    }
}
