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
    
    @AppStorage("dashboard.widget.thismonth") public var showWidgetThisMonth: Bool = true
    
    @Environment(\.managedObjectContext) var moc
    @StateObject public var crm: CoreDataRecords = CoreDataRecords(moc: PersistenceController.shared.container.viewContext)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)", fgColour: .white)
                Spacer()
                FancyButtonv2(
                    text: "Close",
                    action: {showWidgetThisMonth.toggle()},
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
            (wordCount, jobCount, recordCount) = await crm.monthlyStats()
        }
    }
}
