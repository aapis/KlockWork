//
//  ThreePanel.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-04.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

// @TODO: this whole structure needs to be rebuilt to be extensible
struct ThreePanelGroup: View {
    public var orientation: Panel.Orientation
    public var data: any Collection
    public var lastColumnType: LastColumnType

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
                    if lastColumnType == .jobs {
                        JobPanel(position: .last)
                    } else if lastColumnType == .notes {
                        NotePanel(position: .last)
                    }
                }
                .frame(height: 300)
            } else {
                LazyHGrid(rows: columns, alignment: .top, spacing: 1) {
                    CompanyPanel(position: .first)
                    ProjectPanel(position: .middle)
                    if lastColumnType == .jobs {
                        JobPanel(position: .last)
                    } else if lastColumnType == .notes {
                        NotePanel(position: .last)
                    }
                }
            }
        }
        .onAppear(perform: actionOnAppear)
        .onChange(of: nav.session.job) { self.onChangeJob() }
    }
    
    init(orientation: Panel.Orientation, data: any Collection, lastColumnType: LastColumnType) {
        self.orientation = orientation
        self.data = data
        self.lastColumnType = lastColumnType
    }
}

extension ThreePanelGroup {
    private func actionOnAppear() -> Void {
        switch self.data {
        case is FetchedResults<Company>: nav.forms.tp.first = self.data as? FetchedResults<Company>
        case is FetchedResults<Project>: nav.forms.tp.middle = self.data as! [Project]
        case is FetchedResults<Job>: nav.forms.tp.last = self.data as! [Job]
        case is FetchedResults<Note>: nav.forms.tp.last = self.data as! [Note]
        default:
            nav.forms.tp.first = nil
            nav.forms.tp.middle = []
            nav.forms.tp.last = []
        }

        self.onChangeJob()
    }
    
    /// Changing the current session job value requires us to change which items are highlighted in each column. This is done by modifying the
    /// `nav.forms.tp.selected` array
    /// - Parameter job: A Job object
    /// - Returns: Void
    private func onChangeJob() -> Void {
        editorVisible = true
        nav.forms.tp.selected = []

        if let project = self.nav.session.project {
            nav.forms.tp.last = (project.jobs?.allObjects as! [Job]).sorted(by: {$0.jid < $1.jid})
            setSelected(config: Panel.SelectedValueCoordinates(position: .middle, item: project))

            if let company = project.company {
                nav.forms.tp.middle = (company.projects?.allObjects as! [Project]).sorted(by: {$0.name! < $1.name!})
                setSelected(config: Panel.SelectedValueCoordinates(position: .first, item: company))
            }
        }

        if let job = self.nav.session.job {
            setSelected(config: Panel.SelectedValueCoordinates(position: .last, item: job))
        }
    }

    
    /// Adds a panel selection value to the list of selected panel items
    /// - Parameter config: A key/value pair, with position and item fields
    /// - Returns: Void
    private func setSelected(config: Panel.SelectedValueCoordinates) -> Void {
        nav.forms.tp.selected.append(config)
    }
}

extension ThreePanelGroup {
    public enum LastColumnType {
        case jobs, notes
    }
}
