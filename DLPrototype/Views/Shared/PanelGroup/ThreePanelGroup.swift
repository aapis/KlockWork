//
//  ThreePanel.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-04.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

// @TODO: this whole structure needs to be rebuilt to be extensible
struct ThreePanelGroup: View {
    public var orientation: Panel.Orientation
    public var data: any Collection
    
    private var columns: [GridItem] {
        return Array(repeating: .init(.flexible(minimum: 100)), count: 3)
    }

    @EnvironmentObject private var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack {
                // Icons
            }
            if orientation == .horizontal {
                LazyVGrid(columns: columns, alignment: .leading) {
                    CompanyPanel(position: .first)
                    ProjectPanel(position: .middle)
                    JobPanel(position: .last)
                }
                .background(
                    .white.opacity(0.05)
                )
                .frame(minHeight: 300)
            } else {
                LazyHGrid(rows: columns, alignment: .top) {
                    CompanyPanel(position: .first)
                    ProjectPanel(position: .middle)
                    JobPanel(position: .last)
                }
            }
        }
        .onAppear(perform: actionOnAppear)
    }
    
    init(orientation: Panel.Orientation, data: any Collection) {
        self.orientation = orientation
        self.data = data
    }
}

extension ThreePanelGroup {
    private func actionOnAppear() -> Void {
        switch self.data {
        case is FetchedResults<Company>: nav.forms.jobSelector.first = self.data as? FetchedResults<Company>
        case is FetchedResults<Project>: nav.forms.jobSelector.middle = self.data as! [Project]
        case is FetchedResults<Job>: nav.forms.jobSelector.last = self.data as! [Job]
        default: 
            nav.forms.jobSelector.first = nil
            nav.forms.jobSelector.middle = []
            nav.forms.jobSelector.last = []
        }
    }
}
