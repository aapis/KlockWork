//
//  Company.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyDashboard: View {
    public var defaultCompany: Company? = nil

    @State private var searchText: String = ""
    @State private var selected: Int = 0

    @AppStorage("notes.columns") private var numColumns: Int = 3

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var pm: CoreDataProjects

    @StateObject public var cdc: CoreDataCompanies = CoreDataCompanies(moc: PersistenceController.shared.container.viewContext)

    @FetchRequest public var companies: FetchedResults<Company>

    private var columns: [GridItem] {
        return Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }

    public init(company: Company? = nil) {
        self.defaultCompany = company

        let request: NSFetchRequest<Company> = Company.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Company.lastUpdate?, ascending: false),
            NSSortDescriptor(keyPath: \Company.createdDate?, ascending: false)
        ]

        if self.defaultCompany != nil {
            let byJobPredicate = NSPredicate(format: "ANY id = %@", self.defaultCompany!.id!.uuidString)
            let predicates = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [byJobPredicate])
            request.predicate = predicates
        } else {
            request.predicate = NSPredicate(format: "alive = true")
        }

        _companies = FetchRequest(fetchRequest: request, animation: .easeInOut)
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
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
//        .onAppear(perform: load)
    }

    @ViewBuilder private var recent: some View {
        if companies.count > 0 {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, alignment: .leading) {
                    ForEach(filter(companies)) { company in
                        CompanyBlock(company: company)
                            .environmentObject(updater)
                            .environmentObject(pm)
                            .environmentObject(cdc)
                    }
                }
            }
        } else {
            Text("No company names matched your query")
        }
    }

    private func load() -> Void {
        let c = Company(context: moc)
        c.name = "YellowPencil"
        c.createdDate = Date()
        c.lastUpdate = Date()
        c.id = UUID()
        c.alive = true
        c.abbreviation = "YP"

        PersistenceController.shared.save()
    }

    // TODO: keep this, but make it optional
//    @ViewBuilder
//    var allTable: some View {
//        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
//            HStack(spacing: 0) {
//                GridRow {
//                    Group {
//                        ZStack(alignment: .leading) {
//                            Theme.headerColour
//                            Text("Name")
//                                .padding()
//                        }
//                    }
//                    Group {
//                        ZStack {
//                            Theme.headerColour
//                            Text("Versions")
//                                .padding()
//                        }
//                    }
//                    .frame(width: 100)
//                }
//            }
//            .frame(height: 46)
//
//            allRows
//        }
//        .font(Theme.font)
//    }
//
//    @ViewBuilder
//    var allRows: some View {
//        ScrollView(showsIndicators: false) {
//            if companies .count > 0 {
//                VStack(alignment: .leading, spacing: 1) {
//                    ForEach(filter(companies)) { note in
//                        NoteRow(note: note)
//                    }
//                }
//            } else {
//                Text("No notes for this query")
//            }
//        }
//    }

    private func filter(_ companies: FetchedResults<Company>) -> [Company] {
        return SearchHelper(bucket: companies).findInCompanies($searchText)
    }
}

//struct CompanyDashboard_Previews: PreviewProvider {
//    static var previews: some View {
//        Company()
//    }
//}
