//
//  Company.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyDashboard: View {
    @State private var searchText: String = ""
    @State private var selected: Int = 0
    @State private var allowHidden: Bool = false

    @AppStorage("notes.columns") private var numColumns: Int = 3
    @AppStorage("general.defaultCompany") public var defaultCompany: Int = 0

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    @FetchRequest public var companies: FetchedResults<Company>

    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .companies
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Companies & Projects", imageAsImage: eType.icon)
                    Spacer()
                    FancyButtonv2(
                        text: "New Company",
                        action: {},
                        icon: "building.2",
                        redirect: AnyView(CompanyCreate()),
                        pageType: .companies,
                        sidebar: AnyView(DefaultCompanySidebar())
                    )
                    FancyButtonv2(
                        text: "New Project",
                        action: {},
                        icon: "folder.badge.plus",
                        redirect: AnyView(ProjectCreate()),
                        pageType: .companies,
                        sidebar: AnyView(DefaultCompanySidebar())
                    )
                }

                if companies.count > 0 {
                    FancyHelpText(
                        text: "Build your data hierarchy by creating companies, which own projects. Projects own jobs, which define what needs to be done.",
                        page: self.page
                    )
                    Recent
                } else {
                    FancyHelpText(
                        text: "No companies found",
                        page: self.page
                    )
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }

    @ViewBuilder private var Recent: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: self.columns, alignment: .leading, spacing: 10) {
                ForEach(self.companies, id: \.objectID) { company in
                    CompanyBlock(company: company)
                }
            }
        }
    }
}

extension CompanyDashboard {
    init(company: Company? = nil) {
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Company.name, ascending: true)
        ]

        request.predicate = NSPredicate(format: "alive = true")

        _companies = FetchRequest(fetchRequest: request, animation: .easeInOut)
    }
}
