//
//  Outline.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct Outline: View {
    @FetchRequest public var companies: FetchedResults<Company>
    @FetchRequest public var unowned: FetchedResults<Project>

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                }
                ForEach(companies) { company in
                    Group {
                        FancyTextLink(text: company.name!, destination: AnyView(CompanyView(company: company)), pageType: .companies, sidebar: AnyView(DefaultCompanySidebar()))
                        ProjectOutline(company: company)
                    }
                }

                if unowned.count > 0 {
                    Text("Unowned Projects")
                    ForEach(unowned) { project in
                        HStack {
                            Image(systemName: "arrow.turn.down.right")
                            FancyTextLink(text: project.name!, destination: AnyView(ProjectView(project: project)), pageType: .projects, sidebar: AnyView(ProjectsDashboardSidebar()))
                        }
                        .padding([.leading], 10)
                    }
                }
            }
            .padding(5)
        }
        .background(Theme.base.opacity(0.2))
    }
}

extension Outline {
    public init(company: Company? = nil) {
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Company.lastUpdate?, ascending: false),
            NSSortDescriptor(keyPath: \Company.createdDate?, ascending: false)
        ]
        request.predicate = NSPredicate(format: "alive = true")

        _companies = FetchRequest(fetchRequest: request, animation: .easeInOut)

        let pRequest: NSFetchRequest<Project> = Project.fetchRequest()
        pRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Project.lastUpdate?, ascending: false),
            NSSortDescriptor(keyPath: \Project.created?, ascending: false)
        ]
        pRequest.predicate = NSPredicate(format: "alive = true && company.pid = nil")

        _unowned = FetchRequest(fetchRequest: pRequest, animation: .easeInOut)
    }
}

struct ProjectOutline: View {
    public var company: Company

    @FetchRequest public var projects: FetchedResults<Project>

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(projects) { project in
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                    FancyTextLink(text: project.name!, destination: AnyView(ProjectView(project: project)), pageType: .projects, sidebar: AnyView(ProjectsDashboardSidebar()))
                }
                .padding([.leading], 10)
            }
        }
    }
}

extension ProjectOutline {
    public init(company: Company) {
        self.company = company

        let pRequest: NSFetchRequest<Project> = Project.fetchRequest()
        pRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Project.lastUpdate?, ascending: false),
            NSSortDescriptor(keyPath: \Project.created?, ascending: false)
        ]
        pRequest.predicate = NSPredicate(format: "alive = true && company.pid = %d", company.pid)

        _projects = FetchRequest(fetchRequest: pRequest, animation: .easeInOut)
    }
}
