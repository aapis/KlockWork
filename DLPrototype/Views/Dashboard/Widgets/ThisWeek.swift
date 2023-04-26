//
//  ThisWeek.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import CreateML

struct ThisWeek: View {
    public let title: String = "This Week"
    
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
        let recordsInPeriod = await crm.waitForRecent(1)
        let wc = crm.countWordsIn(recordsInPeriod)
        let jc = crm.countJobsIn(recordsInPeriod)
        
//        randomMlShit()
        
        return (wc, jc, recordsInPeriod.count)
    }
    
    private func randomMlShit() -> Void {
//        let complexDict: [String: Array<String>] = [
//            "411150.0": [
//                "ok we were mainly just proofing the functionality. all is good, we have a full checklist of post-launch items now",
//                "unclear what this meeting is about, we are editing code locally and watching?",
//                "in related meeting: OnPoint Search - Dry run",
//                "pausing to prepare for a project-related meeting",
//                "working on this task: Date selector"
//            ],
//            "11.0": [
//                "prepping for 1:1",
//                "in 1:1",
//                "done"
//            ],
//            "55.0": [
//                "in standup",
//                "done"
//            ]
//        ]
//
//        let dict: [String: MLDataValueConvertible] = [
//            "411150.0": "ok we were mainly just proofing the functionality. all is good, we have a full checklist of post-launch items now",
//            "11.0": "prepping for 1:1",
//            "55.0": "in standup"
//        ]
//
//        let toklab: [String: MLDataValueConvertible] = [
//            "tokens": [
//                "ok we were mainly just proofing the functionality. all is good, we have a full checklist of post-launch items now",
//                "unclear what this meeting is about, we are editing code locally and watching?",
//                "in related meeting: OnPoint Search - Dry run",
//                "pausing to prepare for a project-related meeting",
//                "working on this task: Date selector"
//            ],
//            "labels": [
//                "411150.0",
//                "411150.0",
//                "411150.0",
//                "11.0",
//                "55.0"
//            ]
//        ]
        
        let file = Bundle.main.url(forResource: "job_ids", withExtension: ".json")
        
        if file == nil {
            print("[error] No file with name job_ids.json")
            return
        } else {
            let contents = try? String(contentsOf: file!)
            print("[debug] Contents: \(contents)")
        }
        
        let kw = Keywords(from: file!)
    }
}
