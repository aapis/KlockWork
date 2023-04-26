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
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var crm: CoreDataRecords
    
    var body: some View {
        VStack(alignment: .leading) {
            FancySubTitle(text: "\(title)")
            Divider()
            
            StatsWidget(wordCount: $wordCount, jobCount: $jobCount, recordCount: $recordCount)
            Spacer()
        }
        .padding()
        .border(Theme.darkBtnColour)
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() -> Void {
        Task {
            (wordCount, jobCount, recordCount) = await calculateStats()
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