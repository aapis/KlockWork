//
//  JobProjectGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobProjectGroup: View {
    public let index: Int
    public let key: Project
    public var jobs: Dictionary<Project, [Job]>
    public var location: WidgetLocation

    @State private var minimized: Bool = false

    @EnvironmentObject public var nav: Navigation

    @AppStorage("widget.jobpicker.minimizeAll") private var minimizeAll: Bool = false

    var body: some View {
        let colour = Color.fromStored(key.colour ?? Theme.rowColourAsDouble)
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                if let job = nav.session.job {
                    if job.project == key {
                        FancyStar(background: Color.fromStored(key.colour ?? Theme.rowColourAsDouble))
                            .help("Records you create will be associated with a job in this project (#\(job.jid.string))")
                    }
                }

                FancyButtonv2(
                    text: key.name!,
                    action: minimize,
                    icon: minimized ? "plus" : "minus",
                    fgColour: minimized ? (colour.isBright() ? .black : .white) : .white,
                    showIcon: false,
                    size: .link
                )
                Spacer()
                FancyButtonv2(
                    text: key.name!,
                    action: minimize,
                    icon: minimized ? "plus" : "minus",
                    fgColour: minimized ? (colour.isBright() ? .black : .white) : .white,
                    showLabel: false,
                    size: .tinyLink,
                    type: .clear
                )
            }
            .padding(8)
        }
        .background(colour)
        .onAppear(perform: actionOnAppear)

        if !minimized {
            VStack(alignment: .leading, spacing: 5) {
                if let subtasks = self.jobs[key] {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(subtasks.filter {$0.id != nil}, id: \.objectID) { job in
                            JobRowPicker(job: job, location: location)
                        }
                    }
                }
            }
            .foregroundColor(colour.isBright() ? .black : .white)
        }

        FancyDivider(height: 8)
    }
}

extension JobProjectGroup {
    private func minimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func actionOnAppear() -> Void {
        minimized = minimizeAll
    }
}
