//
//  ProjectBlock.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-23.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct ProjectBlock: View {
    typealias UI = WidgetLibrary.UI
    @EnvironmentObject public var state: Navigation
    public var project: Project
    @State private var highlighted: Bool = false
    @State private var jobCount: Int = 0

    var body: some View {
        Button {
            self.state.session.project = self.project
            self.state.to(.projectDetail)
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    (project.alive ? project.backgroundColor : Color.gray)
                        .shadow(color: .black.opacity(1), radius: 3)
                        .opacity(highlighted ? 0.4 : 0.3)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Image(systemName: self.highlighted ? "folder.fill" : "folder")
                                .foregroundStyle(self.project.company?.isDefault ?? false ? .yellow : self.highlighted ? project.backgroundColor.opacity(1) : project.backgroundColor.opacity(0.5))
                                .font(.system(size: 60))
                            VStack(alignment: .leading) {
                                Text(project.name ?? "_COMPANY_NAME")
                                    .multilineTextAlignment(.leading)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                                HStack(alignment: .center) {
                                    Spacer()
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
        .clipShape(.rect(cornerRadius: 5))
        .onAppear(perform: self.actionOnAppear)
        .useDefaultHover({inside in highlighted = inside})
        .buttonStyle(.plain)
    }
}

extension ProjectBlock {
    private func actionOnAppear() -> Void {
        if let jobs = self.project.jobs?.allObjects as? [Job] {
            self.jobCount += jobs.count(where: {$0.alive})
        }
    }
}
