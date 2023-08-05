//
//  ProjectRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ProjectRow: View {
    public var project: Project
    
    @EnvironmentObject public var jm: CoreDataJob
    
    var body: some View {
        GridRow {
            HStack(spacing: 1) {
                pColour(project)
                pLink(project)
                pJob(project)
                pAlive(project)
            }
        }
    }
    
    @ViewBuilder private func pColour(_ project: Project) -> some View {
       Group {
            ZStack(alignment: .leading) {
                Color.fromStored(project.colour ?? Theme.rowColourAsDouble)
            }
        }
        .frame(width: 5)
    }
    
    @ViewBuilder private func pLink(_ project: Project) -> some View {
        Group {
            ZStack(alignment: .leading) {
                Theme.rowColour
                FancyTextLink(text: project.name!, destination: AnyView(ProjectView(project: project).environmentObject(jm)), pageType: .projects)
                    .padding(.leading, 10)
            }
        }
    }
    
    @ViewBuilder private func pJob(_ project: Project) -> some View {
        Group {
            ZStack {
                Theme.rowColour
                Text("\(project.jobs!.count)")
                    .padding()
            }
        }
        .frame(width: 100)
    }
    
    @ViewBuilder private func pAlive(_ project: Project) -> some View {
        Group {
            ZStack(alignment: .leading) {
                (project.alive ? Theme.rowStatusGreen : Color.red.opacity(0.2))
            }
        }
        .frame(width: 5)
    }
}
