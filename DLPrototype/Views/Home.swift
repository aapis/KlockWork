//
//  ContentView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-09.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import Combine
import SwiftUI

struct Category: Identifiable {
    var id = UUID()
    var title: String
}

struct Home: View {
    @ObservedObject public var records: Records    
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        Add(category: Category(title: "Daily"), records: records)
                    } label: {
                        HStack {
                            Image(systemName: "doc.append.fill")
                                .padding(.trailing, 10)
                            Text("Today")
                        }.padding(10)
                    }
                    
                    NavigationLink {
                        Search(category: Category(title: "Daily"), records: records)
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .padding(.trailing, 10)
                            Text("Search")
                        }.padding(10)
                    }
                    
                    NavigationLink {
                        CalendarView(category: Category(title: "Daily"), records: records)
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                                .padding(.trailing, 10)
                            Text("Calendar")
                        }.padding(10)
                    }
                    
                    NavigationLink {
                        Backup(category: Category(title: "Daily"))
                    } label: {
                        HStack {
                            Image(systemName: "cloud.fill")
                                .padding(.trailing, 10)
                            Text("Backup")
                        }.padding(10)
                    }
                } header: {
                    Text("Pages")
                }
            }.listStyle(.sidebar)
        }
    }
}

struct HomePreview: PreviewProvider {
    static var previews: some View {
        Home(records: Records())
    }
}
