//
//  RecentJobsWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct RecentJobsWidget: View {
    public let title: String = "Recent Jobs"

    @State private var minimized: Bool = false

    @FetchRequest public var resource: FetchedResults<Job>

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)")
                Spacer()
                FancyButtonv2(
                    text: "Minimize",
                    action: actionMinimize,
                    icon: minimized ? "plus" : "minus",
                    showLabel: false,
                    type: .white
                )
                .frame(width: 30, height: 30)
            }

            if !minimized {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(resource) { job in
                        JobRowPlain(job: job)
                    }
                }
            }
        }
    }
}

extension RecentJobsWidget {
    public init() {
        _resource = CoreDataJob.fetchRecentJobs(limit: 5)
    }
    
    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }
}
