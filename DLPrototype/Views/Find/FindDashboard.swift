//
//  LinkDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct RecentSearch: Identifiable {
    let id: UUID = UUID()
    var term: String
}

struct FindDashboard: View {
    @Binding public var searching: Bool

    @State private var searchText: String = ""
    @State private var activeSearchText: String = ""
    @State private var showRecords: Bool = true
    @State private var showNotes: Bool = true
    @State private var showTasks: Bool = true
    @State private var showProjects: Bool = true
    @State private var showJobs: Bool = true
    @State private var allowAlive: Bool = true
    
    @EnvironmentObject public var jm: CoreDataJob
    
    var body: some View {
        // TODO: commented out to experiment including this view on the dashboard
//        VStack(alignment: .leading) {
//            VStack(alignment: .leading) {
//                search
//
//                Spacer()
//            }
//            .font(Theme.font)
//            .padding()
//        }
//        .background(Theme.toolbarColour)
        search
    }
    
    @ViewBuilder
    var search: some View {
        // TODO: commented out to experiment including this view on the dashboard
//        HStack {
//            Title(text: "Find", image: "magnifyingglass")
//            Spacer()
//        }
        
        Grid(horizontalSpacing: 0, verticalSpacing: 1) {
            GridRow {
                SearchBar(
                    text: $activeSearchText,
                    disabled: false,
                    placeholder: "Hit enter to search",
                    onSubmit: onSubmit,
                    onReset: onReset
                )
                .onChange(of: searchText) { _ in
                    onSubmit()
                }
            }
            
            GridRow {
                ZStack(alignment: .leading) {
                    Theme.subHeaderColour
                    
                    HStack {
                        Toggle("Records", isOn: $showRecords)
                        Toggle("Notes", isOn: $showNotes)
                        Toggle("Tasks", isOn: $showTasks)
                        Toggle("Projects", isOn: $showProjects)
                        Toggle("Jobs", isOn: $showJobs)
                        // TODO: re-add at some point
//                        Spacer()
//                        Toggle("Show alive", isOn: $allowAlive)
                    }
                    .padding([.leading, .trailing], 10)
                }
            }
            .frame(height: 40)
            
            if !activeSearchText.isEmpty {
                FancyDivider()
                
                Results(
                    text: $searchText,
                    showRecords: $showRecords,
                    showNotes: $showNotes,
                    showTasks: $showTasks,
                    showProjects: $showProjects,
                    showJobs: $showJobs,
                    allowAlive: $allowAlive
                )
                .environmentObject(jm)
            }
        }
    }
    
    @ViewBuilder
    var loading: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                ProgressView("Searching...")
                Spacer()
            }
            .padding([.top, .bottom], 20)
        }
    }
    
    private func onSubmit() -> Void {
        if activeSearchText != "" {
            searching = true
        } else {
            searching = false
        }

        searchText = activeSearchText
    }

    private func onReset() -> Void {
        searching = false
    }
}
