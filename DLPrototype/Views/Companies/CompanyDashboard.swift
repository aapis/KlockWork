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

    @AppStorage("notes.columns") private var numColumns: Int = 3

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater

    @FetchRequest public var companies: FetchedResults<Company>

    private var columns: [GridItem] {
        Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }

    public init(company: Company? = nil) {
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Company.lastUpdate?, ascending: false),
            NSSortDescriptor(keyPath: \Company.createdDate?, ascending: false)
        ]

        request.predicate = NSPredicate(format: "alive = true")

        _companies = FetchRequest(fetchRequest: request, animation: .easeInOut)
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "\(companies.count) Companies")
                    Spacer()
                    FancyButtonv2(
                        text: "New company",
                        action: {},
                        icon: "plus",
                        showLabel: false,
                        redirect: AnyView(CompanyCreate()),
                        pageType: .companies,
                        sidebar: AnyView(DefaultCompanySidebar())
                    )
                }
                
                SearchBar(
                    text: $searchText,
                    disabled: false,
                    placeholder: companies.count > 1 ? "Search \(companies.count) companies" : "Search 1 company"
                )

                recent

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }

    @ViewBuilder private var recent: some View {
        if companies.count > 0 {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                    ForEach(filter(companies)) { company in
                        CompanyBlock(company: company)
                    }
                }
            }
        } else {
            Text("No company names matched your query")
        }
    }
}

extension CompanyDashboard {
    private func filter(_ companies: FetchedResults<Company>) -> [Company] {
        return SearchHelper(bucket: companies).findInCompanies($searchText)
    }
}

//struct CompanyDashboard_Previews: PreviewProvider {
//    static var previews: some View {
//        Company()
//    }
//}
