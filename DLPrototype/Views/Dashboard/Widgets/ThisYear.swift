//
//  ThisYear.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ThisYear: View {
    public let title: String = "This Year"
    
    @State private var wordCount: Int = 0
    @State private var jobCount: Int = 0
    @State private var recordCount: Int = 0
    
    @AppStorage("dashboard.widget.thisyear") public var showWidgetThisYear: Bool = true
    
    @Environment(\.managedObjectContext) var moc
    @StateObject public var crm: CoreDataRecords = CoreDataRecords(moc: PersistenceController.shared.container.viewContext)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)", fgColour: .white)
                Spacer()
                FancyButtonv2(
                    text: "Close",
                    action: {showWidgetThisYear.toggle()},
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
                WidgetLoading()
            } else {
                StatsWidget(wordCount: $wordCount, jobCount: $jobCount, recordCount: $recordCount)
            }

            Spacer()
        }
        .background(Theme.cPurple)
        .onAppear(perform: onAppear)
        .frame(height: 250)
    }
    
    private func onAppear() -> Void {
        Task {
            (wordCount, jobCount, recordCount) = await calculateStats() // TODO: figure out why crm.yearlyStats crashes app
        }
    }
    
    private func calculateStats() async -> (Int, Int, Int) {
        let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
        let recordsInPeriod = await crm.waitForRecent(Double(currentWeek))
        let wc = crm.countWordsIn(recordsInPeriod)
        let jc = crm.countJobsIn(recordsInPeriod)
        
        return (wc, jc, recordsInPeriod.count)
    }
}
