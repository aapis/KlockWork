//
//  CompanyDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyDetail: View {
    public let company: Company
    
    @State private var projects: [Project] = []
    @State private var isDefault: Bool = false

    var body: some View {
        VStack {
            List {
                Section("Projects") {
                    if projects.count > 0 {
                        ForEach(projects) { project in
                            Text(project.name!.capitalized)
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
        .navigationTitle(company.name!.capitalized)
    }
}

extension CompanyDetail {
    private func actionOnAppear() -> Void {
        projects = company.projects?.allObjects as! [Project]
    }
}
