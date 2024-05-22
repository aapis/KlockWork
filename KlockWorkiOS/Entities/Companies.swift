//
//  Companies.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Companies: View {
    @State public var items: [Company] = []
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(items) { item in
                        NavigationLink {
                            CompanyDetail(company: item)
                        } label: {
                            Text(item.name!.capitalized)
                        }
                    }
                }
//                .onDelete(perform: deleteItems)
            }
            .onAppear(perform: {
                items = CoreDataCompanies(moc: moc).alive()
            })
            .navigationTitle("Companies")
            .toolbarBackground(Theme.cPurple, for: .navigationBar)
            .toolbar {
                ToolbarItem {
                    Button(action: {}/*addItem*/) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
}
