//
//  JobDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobDashboard: View {
    var defaultSelectedJob: Job?

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    if defaultSelectedJob == nil {
                        Title(text: "Find or create a new job")
                    }
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

                About()

                if let jerb = defaultSelectedJob {
                    JobView(job: jerb)
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: defaultSelectedJob, perform: actionOnChange)
    }
}

extension JobDashboard {
    private func actionOnAppear() -> Void {

    }

    private func actionOnChange(job: Job?) -> Void {

    }
}

extension JobDashboard {
    struct About: View {
        private let copy: String = "Perform a search using the sidebar widget or create a new job using the \"New Job\" (or +) button."

        var body: some View {
            VStack {
                HStack {
                    Text(copy).padding(15)
                    Spacer()
                }
            }
            .background(Theme.cOrange)
        }
    }
}

struct JobDashboardRedux: View {
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "hammer")
                        Text("Jobs")
                    }
                    .font(.title2)
                    Spacer()
                    FancyButtonv2(
                        text: "Create",
                        action: {},
                        icon: "plus",
                        showLabel: false,
                        redirect: AnyView(JobCreate()),
                        pageType: .jobs,
                        sidebar: AnyView(JobDashboardSidebar())
                    )
                }
                
                FancyDivider()
                
                JobExplorer()

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
}

struct JobExplorer: View {
    @AppStorage("jobdashboard.explorerVisible") private var explorerVisible: Bool = true
    @AppStorage("jobdashboard.editorVisible") private var editorVisible: Bool = true

    @EnvironmentObject private var nav: Navigation

    @FetchRequest private var companies: FetchedResults<Company>

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text("Explorer").font(.title2)
                    Spacer()
                    FancySimpleButton(
                        text: explorerVisible ? "Close" : "Open",
                        action: {explorerVisible.toggle()},
                        icon: explorerVisible ? "minus.square.fill" : "plus.square.fill",
                        showLabel: false,
                        showIcon: true,
                        size: .tiny,
                        type: .clear
                    )
                }
                
                HStack {
                    Text("Choose a job by first selecting the company, then project, it is associated with.")
                        .font(.caption)
                    Spacer()
                }
            }
            .padding(5)
            .background(.white.opacity(0.2))
            .foregroundStyle(.white)
            
            if explorerVisible {
                ThreePanelGroup(orientation: .horizontal, data: companies)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text("Editor").font(.title2)
                    Spacer()
                    FancySimpleButton(
                        text: editorVisible ? "Close" : "Open",
                        action: {editorVisible.toggle()},
                        icon: editorVisible ? "minus.square.fill" : "plus.square.fill",
                        showLabel: false,
                        showIcon: true,
                        size: .tiny,
                        type: .clear
                    )
                }

                HStack {
                    Text("Modify the Active job.")
                        .font(.caption)
                    Spacer()
                }
                
            }
            .padding(5)
            .background(.white.opacity(0.2))
            .foregroundStyle(.white)
            
            if editorVisible {
                if nav.session.job != nil {
                    VStack {
                        JobView(job: nav.session.job!)
                    }
                    .padding(5)
                    .background(Theme.rowColour)
                    .foregroundStyle(.white)
                } else {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Text("No job selected")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                        .background(Theme.rowColour)
                        
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: nav.saved) { status in
            editorVisible = status
        }
    }
    
    init() {
        _companies = CoreDataCompanies.all()
    }
}
