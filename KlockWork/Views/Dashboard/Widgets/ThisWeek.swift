//
//  ThisWeek.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore
import CreateML

struct ThisWeek: View {
    @EnvironmentObject private var state: Navigation
    @AppStorage("dashboard.widget.thisweek") public var showWidgetThisWeek: Bool = true
    @StateObject public var crm: CoreDataRecords = CoreDataRecords(moc: PersistenceController.shared.container.viewContext)
    public let title: String = "This Week"
    @State private var wordCount: Int = 0
    @State private var jobCount: Int = 0
    @State private var recordCount: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)", fgColour: .white)
                Spacer()
                FancyButtonv2(
                    text: "Close",
                    action: {showWidgetThisWeek.toggle()},
                    icon: "xmark",
                    showLabel: false,
                    showIcon: true,
                    size: .tiny,
                    type: .clear
                )
            }
            .padding()
            .background(Theme.darkBtnColour)
            
            if recordCount == 0 {
                UI.WidgetLoading()
            } else {
                StatsWidget(wordCount: $wordCount, jobCount: $jobCount, recordCount: $recordCount)
            }
            
            Spacer()
        }
        .background(self.state.session.appPage.primaryColour)
        .onAppear(perform: onAppear)
        .frame(height: 250)
    }
}

extension ThisWeek {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func onAppear() -> Void {
        Task {
            (wordCount, jobCount, recordCount) = await crm.weeklyStats {

            }
        }
    }
}
