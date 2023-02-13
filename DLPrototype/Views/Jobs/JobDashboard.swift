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
    public var defaultSelectedJob: Double? = 0.0
    
    @State private var selectedJob: Int = 0
    @State private var job: Job?
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid, order: .reverse)]) public var jobs: FetchedResults<Job>
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                create

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    @ViewBuilder
    var create: some View {
        HStack {
            Title(text: "Manage jobs", image: "hammer")
            Spacer()
        }
        
        JobPicker(onChange: change)
            .onAppear(perform: setJob)
            .onChange(of: selectedJob) { _ in
                setJob()
            }
        
        if selectedJob > 0 || defaultSelectedJob! > 0.0 {
            JobView(job: $job)
        }
    }
    
    private func setJob() -> Void {
        if defaultSelectedJob! > 0.0 {
            job = CoreDataJob(moc: moc).byId(defaultSelectedJob!)
        }
        
        if selectedJob > 0 {
            job = CoreDataJob(moc: moc).byId(Double(selectedJob))
        }
    }
    
    private func change(selected: Int, sender: String?) -> Void {
        selectedJob = selected
        
        setJob()
    }
}
