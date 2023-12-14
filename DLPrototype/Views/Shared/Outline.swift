//
//  Outline.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct Outline: View {
    @AppStorage("general.defaultCompany") public var defaultCompany: Int = 0

    @FetchRequest public var companies: FetchedResults<Company>
    @FetchRequest public var unowned: FetchedResults<Project>

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "menucard")
                    Text("Outline view")
                }
                Divider()

                if companies.count > 0 {
                    ForEach(companies) { company in
                        Group {
                            HStack {
                                if company.isDefault {
                                    Image(systemName: "building.2")
                                }
                                FancyTextLink(text: company.name!.capitalized, destination: AnyView(CompanyView(company: company)), pageType: .companies, sidebar: AnyView(DefaultCompanySidebar()))
                                    .help("Edit company: \(company.name!.capitalized)")
                                Spacer()
                            }
                            ProjectOutline(company: company)
                        }
                    }
                } else {
                    HStack {
                        FancyTextLink(text: "No companies yet, create one!", destination: AnyView(CompanyCreate()), pageType: .companies, sidebar: AnyView(DefaultCompanySidebar()))
                        Spacer()
                    }
                }

                if unowned.count > 0 {
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Unowned Projects")
                        ForEach(unowned) { project in
                            HStack {
                                Image(systemName: "arrow.turn.down.right")
                                FancyTextLink(text: "[\(project.abbreviation != nil ? project.abbreviation!.uppercased() : "NOPE")] \(project.name!.capitalized)", destination: AnyView(ProjectView(project: project)), pageType: .companies, sidebar: AnyView(DefaultCompanySidebar()))
                                    .help("Edit project: \(project.name!.capitalized)")
                            }
                            .padding([.leading], 10)
                        }
                    }
                }
            }
            .padding(10)
        }
        .background(Theme.base.opacity(0.2))
        .onAppear(perform: actionOnAppear)
        .onChange(of: defaultCompany) { _ in
            actionOnAppear()
        }
    }
}

extension Outline {
    init(company: Company? = nil) {
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Company.name, ascending: true)
        ]
        request.predicate = NSPredicate(format: "alive = true")

        _companies = FetchRequest(fetchRequest: request, animation: .easeInOut)

        let pRequest: NSFetchRequest<Project> = Project.fetchRequest()
        pRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Project.name, ascending: true)
        ]
        pRequest.predicate = NSPredicate(format: "alive = true && company.pid = nil")

        _unowned = FetchRequest(fetchRequest: pRequest, animation: .easeInOut)
    }

    private func actionOnAppear() -> Void {
        if let company = CoreDataCompanies(moc: moc).byPid(defaultCompany) {
            company.isDefault = true
        }
    }
}

struct ProjectOutline: View {
    public var company: Company

    @FetchRequest public var projects: FetchedResults<Project>

    var body: some View {
        VStack(alignment: .leading) {
            if projects.count > 0 {
                ForEach(projects) { project in
                    HStack {
                        Image(systemName: "arrow.turn.down.right")
                        FancyTextLink(text: "[\(project.abbreviation != nil ? project.abbreviation!.uppercased() : "NOPE")] \(project.name!.capitalized)", destination: AnyView(ProjectView(project: project)), pageType: .companies, sidebar: AnyView(DefaultCompanySidebar()))
                            .help("Edit project: \(project.name!.capitalized)")
                    }
                    .padding([.leading], 10)
                }
            } else {
                Text("No projects")
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
            NSSortDescriptor(keyPath: \Project.name, ascending: true)
        ]
        pRequest.predicate = NSPredicate(format: "alive = true && company.pid = %d", company.pid)

        _projects = FetchRequest(fetchRequest: pRequest, animation: .easeInOut)
    }
}
