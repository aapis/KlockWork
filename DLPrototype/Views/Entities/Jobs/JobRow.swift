//
//  JobRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobRow: View {
    public var job: Job
    public var colour: Color

    @EnvironmentObject public var nav: Navigation
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)
    
    var body: some View {
        HStack(spacing: 1) {
            project
            
            ZStack(alignment: .leading) {
                colour
                
                HStack {
                    Button {
                        nav.view = AnyView(JobDashboard(defaultSelectedJob: job))
                        nav.parent = .jobs
                        nav.sidebar = AnyView(JobDashboardSidebar())
                        nav.pageId = UUID()
                    } label: {
                        Text(job.jid.string)
                            .foregroundColor(colour.isBright() ? Color.black : Color.white)
                            .padding([.leading, .trailing], 10)
                            .useDefaultHover({_ in})
                            .help("Edit job")
                    }
                    .buttonStyle(.borderless)
                    .underline()
                    
                    if job.uri != nil {
                        Spacer()
                        Link(destination: job.uri!, label: {
                            Image(systemName: "link")
                                .foregroundColor(colour.isBright() ? Color.black : Color.white)
                                .onHover { inside in
                                    if inside {
                                        NSCursor.pointingHand.push()
                                    } else {
                                        NSCursor.pop()
                                    }
                                }
                                .help("Visit job URL on the web")
                        })
                        .padding([.trailing], 5)
                    }
                }
            }.frame(width: 200)
            
            ZStack(alignment: .leading) {
                colour
                
                Text(colour.description.debugDescription)
                    .padding(10)
                    .foregroundColor(colour.isBright() ? Color.black : Color.white)
                    .contextMenu {
                        Button(action: {ClipboardHelper.copy("\(colour)".debugDescription)}, label: {
                            Text("Copy colour code")
                        })
                    }
            }
        }
    }
    
    @ViewBuilder var project: some View {
        Group {
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    if job.project != nil {
                        Color.fromStored(job.project!.colour ?? Theme.rowColourAsDouble)
                    } else {
                        Theme.rowColour
                    }
                }
            }
        }
        .frame(width: 5)
    }
}
