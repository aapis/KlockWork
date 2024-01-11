//
//  ThreePanel.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-04.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

// @TODO: this whole structure needs to be rebuilt to be extensible
struct ThreePanelGroup: View {
    public var orientation: Panel.Orientation
    public var data: any Collection
    
    private var columns: [GridItem] {
        return Array(repeating: .init(.flexible(minimum: 100), spacing: 1), count: 3)
    }

    @AppStorage("jobdashboard.editorVisible") private var editorVisible: Bool = true

    @EnvironmentObject private var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
//            HStack {
//                // Icons
//            }
            if orientation == .horizontal {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
                    CompanyPanel(position: .first)
                    ProjectPanel(position: .middle)
                    JobPanel(position: .last)
                }
                .frame(height: 300)
            } else {
                LazyHGrid(rows: columns, alignment: .top, spacing: 1) {
                    CompanyPanel(position: .first)
                    ProjectPanel(position: .middle)
                    JobPanel(position: .last)
                }
            }
        }
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.session.job) { job in onChangeJob(job: job) }
    }
    
    init(orientation: Panel.Orientation, data: any Collection) {
        self.orientation = orientation
        self.data = data
    }
}

extension ThreePanelGroup {
    private func actionOnAppear() -> Void {
        switch self.data {
        case is FetchedResults<Company>: nav.forms.jobSelector.first = self.data as? FetchedResults<Company>
        case is FetchedResults<Project>: nav.forms.jobSelector.middle = self.data as! [Project]
        case is FetchedResults<Job>: nav.forms.jobSelector.last = self.data as! [Job]
        default: 
            nav.forms.jobSelector.first = nil
            nav.forms.jobSelector.middle = []
            nav.forms.jobSelector.last = []
        }
    }
    
    /// Changing the current session job value requires us to change which items are highlighted in each column. This is done by modifying the
    /// `nav.forms.jobSelector.selected` array
    /// - Parameter job: A Job object
    /// - Returns: Void
    private func onChangeJob(job: Job?) -> Void {
        if job != nil {
            editorVisible = true
            nav.forms.jobSelector.selected = []

            if let project = job!.project {
                nav.forms.jobSelector.last = (project.jobs?.allObjects as! [Job]).sorted(by: {$0.jid < $1.jid})
                setSelected(config: Panel.SelectedValueCoordinates(position: .middle, item: project))

                if let company = project.company {
                    nav.forms.jobSelector.middle = (company.projects?.allObjects as! [Project]).sorted(by: {$0.name! < $1.name!})
                    setSelected(config: Panel.SelectedValueCoordinates(position: .first, item: company))
                }
            }
            setSelected(config: Panel.SelectedValueCoordinates(position: .last, item: job!))
        }
    }

    
    /// Adds a panel selection value to the list of selected panel items
    /// - Parameter config: A key/value pair, with position and item fields
    /// - Returns: Void
    private func setSelected(config: Panel.SelectedValueCoordinates) -> Void {
        nav.forms.jobSelector.selected.append(config)
    }
}
