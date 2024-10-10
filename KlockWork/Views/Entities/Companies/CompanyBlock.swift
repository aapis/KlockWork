//
//  CompanyBlock.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct CompanyBlock: View {
    typealias UI = WidgetLibrary.UI
    @EnvironmentObject public var nav: Navigation
    public var company: Company
    @State private var highlighted: Bool = false
    @State private var projectCount: Int = 0
    @State private var jobCount: Int = 0

    var body: some View {
        Button {
            self.nav.session.company = self.company
            self.nav.to(.companyDetail)
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    (company.alive ? company.backgroundColor : Color.gray)
                        .shadow(color: .black.opacity(1), radius: 3)
                        .opacity(highlighted ? 0.4 : 0.3)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Image(systemName: self.highlighted ? "building.2.crop.circle.fill" : "building.2.crop.circle")
                                .foregroundStyle(self.company.isDefault ? .yellow : self.highlighted ? company.backgroundColor.opacity(1) : company.backgroundColor.opacity(0.5))
                                .font(.system(size: 60))
                            VStack(alignment: .leading) {
                                Text(company.name ?? "_COMPANY_NAME")
                                    .multilineTextAlignment(.leading)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                                HStack(alignment: .center) {
                                    Spacer()
                                    UI.Chip(type: .projects, count: self.projectCount)
                                    UI.Chip(type: .jobs, count: self.jobCount)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding([.leading, .trailing, .top])
                }
            }
        }
        .onAppear(perform: self.actionOnAppear)
        .useDefaultHover({inside in highlighted = inside})
        .help(self.company.isDefault ? "This is your default company." : "")
        .buttonStyle(.plain)
    }
}

extension CompanyBlock {
    private func actionOnAppear() -> Void {
        if let projects = self.company.projects?.allObjects as? [Project] {
            let publishedProjects = projects.filter({$0.alive})

            self.projectCount = publishedProjects.count

            for project in publishedProjects {
                if let jobs = project.jobs?.allObjects as? [Job] {
                    self.jobCount += jobs.count(where: {$0.alive})
                }
            }
        }
    }
}
