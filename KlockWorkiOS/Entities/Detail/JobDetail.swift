//
//  JobDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct JobDetail: View {
    public let job: Job
    
    @State private var alive: Bool = false

    var body: some View {
        VStack {
            List {
                Section("Settings") {
                    Toggle("Published", isOn: $alive)
                }
            }
        }
        .onAppear(perform: actionOnAppear)
        .navigationTitle(job.title != nil ? job.title!.capitalized : job.jid.string)
    }
}

extension JobDetail {
    private func actionOnAppear() -> Void {
        alive = job.alive
//        projects = company.projects?.allObjects as! [Project]
    }
}
