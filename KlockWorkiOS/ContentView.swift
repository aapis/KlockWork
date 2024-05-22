//
//  ContentView.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-18.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import SwiftData

struct NoteView: View {
    public let note: Note
    
    @State private var versions: [NoteVersion] = []
    @State private var current: NoteVersion? = nil
    @State private var content: String = ""
    @State private var title: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    Text(title)
                        .font(.title)
                    Spacer()
                }
            }
            .padding()

            HStack {
                ScrollView(showsIndicators: false) {
                    Text(content)
                }
                .padding()
                Spacer()
            }
            .background(Theme.base)
        }
        .onAppear(perform: actionOnAppear)
        .background(Theme.cPurple)
//        .toolbar {
//            ToolbarItem {
//                Button(action: {}) {
//                    Label("Versions", systemImage: "questionmark.circle")
//                }
//            }
//        }
    }
}

extension NoteView {
    private func actionOnAppear() -> Void {
        if let vers = note.versions {
            versions = vers.allObjects as! [NoteVersion]
            current = versions.first
            
            if let curr = current {
                title = curr.title ?? "_NOTE_TITLE"
                content = curr.content ?? "_NOTE_CONTENT"
            }
        } else if let body = note.body {
            title = note.title ?? "_NOTE_TITLE"
            content = body
        }
    }
}

struct CompanyView: View {
    public let company: Company
    
    @State private var projects: [Project] = []
    @State private var isDefault: Bool = false

    var body: some View {
        VStack {
            List {
                Section("Projects") {
                    if projects.count > 0 {
                        ForEach(projects) { project in
                            Text(project.name!)
                        }
                    } else {
                        Text("No projects found")
                            .foregroundStyle(.gray)
                    }
                }

                Section("Settings") {
                    Toggle("Default company", isOn: $isDefault)
                }
            }
        }
        .onAppear(perform: actionOnAppear)
        .navigationTitle(company.name!)
    }
}

extension CompanyView {
    private func actionOnAppear() -> Void {
        projects = company.projects?.allObjects as! [Project]
    }
}

struct Main: View {
    var body: some View {
        TabView {
            Home()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
            }
            Today()
                .tabItem {
                    Image(systemName: "tray")
                    Text("Today")
            }
            Planning()
                .tabItem {
                    Image(systemName: "hexagon")
                    Text("Planning")
            }
            
            AppSettings()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
            }
        }
    }
}

struct Planning: View {
    var body: some View {
        Text("Coming soon!")
    }
}

struct Today: View {
    var body: some View {
        Text("Coming soon!")
    }
}

struct AppSettings: View {
    var body: some View {
        Text("Coming soon!")
    }
}

struct Home: View {
    private let fgColour: Color = .red
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 2)
    }

    @State private var path = NavigationPath()
    @State private var entityCounts: (Int, Int, Int, Int) = (0,0,0,0)

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Entities") {
                    NavigationLink {
                        Companies()
                            .environment(\.managedObjectContext, moc)
                    } label: {
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundStyle(fgColour)
                            Text("Companies")
                            Spacer()
                            Text(String(entityCounts.0))
                        }
                    }

                    NavigationLink {
                        Notes()
                            .environment(\.managedObjectContext, moc)
                    } label: {
                        HStack {
                            Image(systemName: "hammer")
                                .foregroundStyle(fgColour)
                            Text("Jobs")
                            Spacer()
                            Text(String(entityCounts.1))
                        }
                    }
                    
                    
                    NavigationLink {
                        Notes()
                            .environment(\.managedObjectContext, moc)
                    } label: {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundStyle(fgColour)
                            Text("Notes")
                            Spacer()
                            Text(String(entityCounts.2))
                        }
                    }
                    
                    NavigationLink {
                        Notes()
                            .environment(\.managedObjectContext, moc)
                    } label: {
                        HStack {
                            Image(systemName: "checklist")
                                .foregroundStyle(fgColour)
                            Text("Tasks")
                            Spacer()
                            Text(String(entityCounts.3))
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .toolbarBackground(Theme.cPurple, for: .navigationBar)
            .toolbar {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(fgColour)
            }

//            LazyVGrid(columns: columns) {
//                HStack {
//                    Image(systemName: "hexagon")
//                        .font(.title)
//                    Text("Planning")
//                }
//                .padding()
//                .background(Theme.cPurple)
//                .mask(RoundedRectangle(cornerRadius: 10.0))
//                
//                HStack {
//                    Image(systemName: "tray")
//                        .font(.title)
//                    Text("Today")
//                }
//                .padding()
//                .background(Theme.cPurple)
//                .mask(RoundedRectangle(cornerRadius: 10.0))
//            }
        }
        .accentColor(fgColour)
        .onAppear(perform: actionOnAppear)
    }
}

extension Home {
    private func actionOnAppear() -> Void {
        Task {
            entityCounts = (
                CoreDataCompanies(moc: moc).countAll(),
                CoreDataJob(moc: moc).countAll(),
                CoreDataNotes(moc: moc).alive().count,
                CoreDataTasks(moc: moc).countAllTime()
            )
        }
    }
}

struct Companies: View {
    @State public var items: [Company] = []
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(items) { item in
                        NavigationLink {
                            CompanyView(company: item)
                        } label: {
                            Text(item.name!)
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
            .toolbarBackground(.visible, for: .navigationBar)
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

struct Notes: View {
    @State public var items: [Note] = []

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(items) { item in
                        NavigationLink {
                            NoteView(note: item)
                        } label: {
                            Text(item.title!)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .onAppear(perform: {
                items = CoreDataNotes(moc: moc).alive()
            })
            .navigationTitle("Notes")
            .toolbarBackground(Theme.cPurple, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
//                modelContext.delete(items[index])
            }
        }
    }
}

//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
