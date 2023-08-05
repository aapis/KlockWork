//
//  JobDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct JobDashboard: View {
    public var defaultSelectedJob: Job?
    
    @State private var selectedJob: Int = 0
    @State private var job: Job? // TODO: refactor setJob + remove
    @State private var jobId: String = ""
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var updater: ViewUpdater
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid, order: .reverse)]) public var jobs: FetchedResults<Job>
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                manage

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .id(updater.get("job.dashboard"))
    }
    
    @ViewBuilder
    var manage: some View {
        HStack {
            Spacer()
            FancyButtonv2(
                text: "New job",
                action: {},
                icon: "plus",
                showLabel: false,
                redirect: AnyView(JobCreate()),
                pageType: .jobs,
                sidebar: AnyView(JobDashboardSidebar())
            )
        }
        
        VStack {
            JobPickerUsing(onChange: actionOnChange, jobId: $jobId)
                .onAppear(perform: setJob)
                .onChange(of: selectedJob) { _ in
                    setJob()
                }
        }

        if !jobId.isEmpty {
            JobView(job: job!).environmentObject(jm)
        } else {
            Text("NO JOB")
        }
    }
    
    private func setJob() -> Void {
        if let def = defaultSelectedJob {
            job = def
        } else if selectedJob > 0 {
            job = jm.byId(Double(selectedJob))
        }
        
        if let jerb = job {
            jobId = jerb.jid.string
        }
        print("DERPO job=\(jobId)")
    }
    
    private func actionOnChange(selected: Int, sender: String?) -> Void {
        selectedJob = selected
        setJob()
    }

    private func actionOnAppear() -> Void {
        setJob()
    }
}
