//
//  RecentJobsWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobsWidget: View {
    public var title: String = "Jobs"
    public var location: WidgetLocation = .sidebar

    @FetchRequest public var resource: FetchedResults<Job>

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                Spacer()
            }
            .padding(10)
            .background(Theme.base.opacity(0.2))

            VStack(alignment: .leading, spacing: 5) {
                ForEach(resource) { job in
                    JobRowPlain(job: job, location: location)
                }
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
    }
}

extension JobsWidget {
    public init(location: WidgetLocation? = nil) {
        _resource = CoreDataJob.fetchAll()
        
        if let loc = location {
            self.location = loc
        }
    }

    private func actionSettings() -> Void {
//        isSettingsPresented.toggle()
    }

}
