//
//  Home.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

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
                            .navigationTitle("Companies")
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
                        Jobs()
                            .environment(\.managedObjectContext, moc)
                            .navigationTitle("Jobs")
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
                            .navigationTitle("Notes")
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
                        Tasks()
                            .environment(\.managedObjectContext, moc)
                            .navigationTitle("Tasks")
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
