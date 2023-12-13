//
//  ManageOwnedProjects.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct ManageOwnedProjects: View {
    public let company: Company

    @FetchRequest private var projects: FetchedResults<Project>
    @FetchRequest private var unowned: FetchedResults<Project>

    var body: some View {
        HStack(spacing: 5) {
            VStack(alignment: .leading, spacing: 1) {
                VStack(alignment: .leading, spacing: 20) {
                    FancySubTitle(text: "Associated projects", image: "checkmark")
                    Divider()
                    HStack(spacing: 1) {
                        Text("\(projects.count) selected")
                            .font(Theme.fontCaption)
                        Spacer()

                        if projects.count > 0 {
                            FancyButtonv2(text: "Deselect All", action: deselectAll, icon: "multiply", showLabel: false, size: .tiny)
                                .padding([.trailing], 10)
                        }
                    }
                }
                FancyDivider()

                ForEach(projects) { project in
                    Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
                        GridRow {
                            HStack {
                                FancyButton(text: "Remove project", action: {self.unown(project)}, icon: "multiply", transparent: true, showLabel: false)
                                Text(project.name!)
                                Spacer()
                            }
                        }
                        .background(Theme.rowColour)
                    }
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 1) {
                VStack(alignment: .leading, spacing: 20) {
                    FancySubTitle(text: "Unowned projects", image: "questionmark")
                    Divider()
                    HStack(spacing: 1) {
                        Text("\(unowned.count) unselected")
                            .font(Theme.fontCaption)
                        Spacer()

                        if unowned.count > 0 {
                            FancyButtonv2(text: "Select All", action: selectAll, icon: "plus", showLabel: false, size: .tiny)
                                .padding([.trailing], 10)
                        }
                    }
                }
                FancyDivider()

                ForEach(unowned) { project in
                    Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
                        GridRow {
                            HStack {
                                FancyButton(text: "Add project", action: {self.own(project)}, icon: "plus", transparent: true, showLabel: false)
                                Text(project.name!)
                                Spacer()
                            }
                        }
                        .background(Theme.rowColour)
                    }
                }

                Spacer()
            }
        }
    }
}

extension ManageOwnedProjects {
    init(company: Company) {
        self.company = company

        let pRequest: NSFetchRequest<Project> = Project.fetchRequest()
        pRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Project.name, ascending: true),
        ]
        pRequest.predicate = NSPredicate(format: "alive = true && company.pid = %d", company.pid)

        _projects = FetchRequest(fetchRequest: pRequest, animation: .easeInOut)

        let unownedReq: NSFetchRequest<Project> = Project.fetchRequest()
        unownedReq.sortDescriptors = [
            NSSortDescriptor(keyPath: \Project.name, ascending: true)
        ]
        unownedReq.predicate = NSPredicate(format: "alive = true && company.pid = nil")

        _unowned = FetchRequest(fetchRequest: unownedReq, animation: .easeInOut)
    }

    private func own(_ project: Project) -> Void {
        project.company = company
        PersistenceController.shared.save()
    }

    private func unown(_ project: Project) -> Void {
        project.company = nil
        PersistenceController.shared.save()
    }

    private func selectAll() -> Void {
        for project in unowned {
            self.own(project)
        }
    }

    private func deselectAll() -> Void {
        for project in projects {
            self.unown(project)
        }
    }
}
