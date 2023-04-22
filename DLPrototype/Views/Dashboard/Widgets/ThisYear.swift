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
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            let recordsInPeriod = crm.recent(52)
            let wc = crm.countWordsIn(recordsInPeriod)
            let jc = crm.countJobsIn(recordsInPeriod)
            
            wordCount = wc
            jobCount = jc
            recordCount = recordsInPeriod.count
        }
    }
}
