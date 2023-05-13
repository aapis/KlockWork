//
//  ThisMonth.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ThisMonth: View {
    public let title: String = "This Month"
    
    @State private var wordCount: Int = 0
    @State private var jobCount: Int = 0
    @State private var recordCount: Int = 0
    @State private var loaded: Bool = false
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var crm: CoreDataRecords
    
    var body: some View {
        VStack(alignment: .leading) {
            FancySubTitle(text: "\(title)")
            Divider()
            
            if loaded == false {
                WidgetLoading()
            } else {
                StatsWidget(wordCount: $wordCount, jobCount: $jobCount, recordCount: $recordCount)
            }
            
            Spacer()
        }
        .padding()
        .border(Theme.darkBtnColour)
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() -> Void {
        Task {
            (wordCount, jobCount, recordCount) = await crm.monthlyStats {
                loaded = true
            }
        }
    }
}
