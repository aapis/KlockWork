//
//  Planning.Today.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Planning {
    struct Today: View {
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                Menu()
                ScrollView(.vertical, showsIndicators: false) {
                    let jobs = Array(nav.planning.jobs).sorted(by: {$0.jid > $1.jid})
                    if jobs.count > 0 {
                        ForEach(jobs) { job in
                            VStack(spacing: 1) {
                                Planning.Group(job: job, jobs: jobs)
                            }
                        }
                    } else {
                        HStack {
                            Text("Add jobs using the sidebar widget then select the tasks you'd like to focus on (turn it on by clicking the sidebar's moon icon). This list saves automatically.")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                        .background(Theme.rowColour)
                    }
                }
            }
        }
    }
}

extension Planning.Today {

}
