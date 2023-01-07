//
//  Import.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Import: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.timestamp, order: .reverse)]) public var records: FetchedResults<LogRecord>
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.jid)
        ]
    ) public var jobs: FetchedResults<Job>
    
    @Environment(\.managedObjectContext) var moc
    
    @State private var importText: String = "4/14/2020 - joining weekly team meeting\n4/14/2020 - weekly meeting done\n2018-12-09 12:44 - 11 - lunch done\n2018-12-09 12:45 - 44829 - back on this\n2018-12-09 14:10 - 13 - some things (1hr)\n=========================\n2018-12-12 09:45\n=========================\n2018-12-12 09:45 - 12 - met with people to discuss training session #3 slide deck and document content.  I have several TODOs for this\n2023-01-05 12:05 - 11 - lunching\n2023-01-05 13:05 - 11 - back"
    @State private var importRun: Bool = false
    @State private var importCount: Int = 0
    @State private var linesProcessed: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            Title(text: "Import", image: "square.and.arrow.up.fill")
            
            // MARK: Import view
            TabView {
                VStack {
                    Text("From file: \(getDocumentsDirectory())/allLogs.log")
                    Button(action: importFromFile) {
                        Text("Import")
                    }
                }.tabItem {
                    Text("From File")
                }
                
                VStack {
                    LogTextField(placeholder: "Some text...", lineLimit: 100, onSubmit: {}, transparent: true, text: $importText)
                        
                    Button(action: importFromString) {
                        Text("Import")
                    }
                }.tabItem {
                    Text("From String")
                }
            }
            
            // MARK: status
            VStack {
                // MARK: danger buttons
                HStack {
                    Button(action: burnItAllDown) {
                        Text("Truncate \(records.count) records")
                    }
                    
                    Button(action: testQuery) {
                        Text("timestamp > @%")
                    }
                }
                
                
                Text("Processed \(linesProcessed) lines")

                if importRun {
                    Text("There are now \(importCount) records")
                }
            }
        }
        .padding()
        .background(Theme.toolbarColour)
    }
    
    private func testQuery() -> Void {
        let fetch: NSFetchRequest<LogRecord> = LogRecord.fetchRequest()

        let today = DateHelper.thisAm()
        let twoDays = DateHelper.twoDays()
        let yesterday = DateHelper.yesterday()

        let todayPredicate = NSPredicate(format: "timestamp > %@", twoDays)
        
        
        fetch.predicate = todayPredicate

        do {
            let res = try moc.fetch(fetch)

            for item in res {
                print("FILTER: \([item.job, item.timestamp, item.message])")
            }
        } catch {
            print("Couldn't find records for today")
        }
    }
    
    private func importFromFile() -> Void {
        let records = Records()
        let rows = records.readFile("allLogs.log")
        
        importRecords(rows.joined(separator: "\n"))
    }
    
    private func importFromString() -> Void {
        importRecords(importText)
    }
    
    private func importRecords(_ contents: String) -> Void {
        for line in contents.split(separator: "\n") {
            // ignore new day rows bound rows
            if line.contains("======") {
                continue
            }
            
            let parts = line.split(separator: " - ")
            
            // new day bounds wrap a single date, so skip if this is the contents of the string
            if parts.count == 1 {
                continue
            }
            
            let job: Double = Double(parts[1]) ?? 0.0
            
            if job > 0 {
                do {
                    let jid = job // copy-pasted this bit
                    let record = LogRecord(context: moc)
                    record.timestamp = try dateFor(String(parts[0])) // pain point
                    record.id = UUID()
                    record.message = String(parts[2])
                    
                    if !jobs.contains(where: { $0.jid == jid }) {
                        let job = Job(context: moc)
                        job.jid = jid
                        job.id = UUID()
                        
                        job.colour = Color.randomStorable()
                        
                        record.job = job
                    }
                    
                    PersistenceController.shared.save()
                } catch {
                    print("OMG")
                }
            }
        }
        
        importRun = true
        importCount = records.count
    }
    
    private func burnItAllDown() -> Void {
        for record in records {
            moc.delete(record)
            
            PersistenceController.shared.save()
        }
    }
    
    // THIS IS WRONG
    private func dateFor(_ timestamp: String) throws -> Date {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.timeZone = TimeZone(abbreviation: "MST")
        inputDateFormatter.locale = NSLocale.current
        inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateObj = inputDateFormatter.date(from: timestamp)
        
        return dateObj!
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)

        return paths[0]
    }
}

struct ImportPreview: PreviewProvider {
    static var previews: some View {
        Import().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
