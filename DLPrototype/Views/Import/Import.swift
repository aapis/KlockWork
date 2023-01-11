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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.timestamp)]) public var records: FetchedResults<LogRecord>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.postedDate)]) public var notes: FetchedResults<Note>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid)]) public var jobs: FetchedResults<Job>
    
//    @State private var isDeleteConfirmationPresented: Bool = false
    
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject public var recordsModel: LogRecords
    
    @State private var importText: String = "4/14/2020 - joining weekly team meeting\n4/14/2020 - weekly meeting done\n2018-12-09 12:44 - 11 - lunch done\n2018-12-09 12:45 - 44829 - back on this\n2018-12-09 14:10 - 13 - some things (1hr)\n=========================\n2018-12-12 09:45\n=========================\n2018-12-12 09:45 - 12 - met with people to discuss training session #3 slide deck and document content.  I have several TODOs for this\n2023-01-05 12:05 - 11 - lunching\n2023-01-05 13:05 - 11 - back"
    @State private var importRun: Bool = false
    @State private var importCount: Int = 0
    @State private var linesProcessed: Int = 0
    @State private var exportText: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Title(text: "Import", image: "square.and.arrow.up.fill")
            
            // MARK: Import view
            TabView {
                VStack {
                    Text("From file: \(getDocumentsDirectory())/allLogs.log")
                    FancyButton(text: "Import", action: importFromFile)
                }.tabItem {
                    Text("From File")
                }
                
                VStack {
                    FancyTextField(placeholder: "Some text...", lineLimit: 100, onSubmit: {}, transparent: true, text: $importText)
                        
                    FancyButton(text: "Import", action: importFromString)
                }.tabItem {
                    Text("From String")
                }
                
                VStack {
                    FancyTextField(placeholder: "Export data", lineLimit: 100, onSubmit: {}, transparent: true, text: $exportText)
                        
                    FancyButton(text: "Export", action: exportToString)
                }.tabItem {
                    Text("Export")
                }
            }
            
            // MARK: status
            VStack {
//                // MARK: danger button(s)
//                HStack {
//                    FancyButton(text: "Truncate \(records.count) Records + Jobs", action: showDelete)
//                    .confirmationDialog("Did you backup first?", isPresented: $isDeleteConfirmationPresented) {
//                        Button("Yes", role: .destructive) {
//                            burnRecordsAndJobs()
//                        }
//                        Button("Cancel", role: .cancel) {
//                            hideDelete()
//                        }
//                    }
//
//                    FancyButton(text: "Truncate \(notes.count) Notes", action: showDelete)
//                    .confirmationDialog("Did you backup first?", isPresented: $isDeleteConfirmationPresented) {
//                        Button("Yes", role: .destructive) {
//                            burnNotes()
//                        }
//                        Button("Cancel", role: .cancel) {
//                            hideDelete()
//                        }
//                    }
//                }
                
                if importRun {
                    Text("Processed \(linesProcessed) lines")
                    Text("There are now \(importCount) records")
                }
            }
        }
        .padding()
        .background(Theme.toolbarColour)
    }
    
    private func exportToString() -> Void {
        for record in records {
            exportText += "\(record.timestamp!) - \(record.job?.jid.string ?? "0") - \(record.message!)\n"
        }
    }
    
    private func importFromFile() -> Void {
        let rows = FileHelper.readFile("allLogs.log")
        
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
                    record.timestamp = try dateFor(String(parts[0]))
                    record.id = UUID()
                    record.message = String(parts[2])
                    
                    let recordsArray = records.map {$0}
                    let (success, matchedJob) = recordsModel.jobMatchWithSet(jid, recordsArray)
                    
                    if !success {
                        let job = Job(context: moc)
                        job.jid = jid
                        job.id = UUID()
                        
                        job.colour = Color.randomStorable()
                        
                        record.job = job
                    } else {
                        record.job = matchedJob
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
    
//    private func burnRecordsAndJobs() -> Void {
//        for record in records {
//            moc.delete(record)
//            
//            PersistenceController.shared.save()
//        }
//        
//        for job in jobs {
//            moc.delete(job)
//            
//            PersistenceController.shared.save()
//        }
//    }
//    
//    private func burnNotes() -> Void {
//        for note in notes {
//            moc.delete(note)
//            
//            PersistenceController.shared.save()
//        }
//    }
    
    private func dateFor(_ timestamp: String) throws -> Date {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.timeZone = TimeZone(abbreviation: "MST")
        inputDateFormatter.locale = NSLocale.current
        inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = inputDateFormatter.date(from: timestamp)
        
        if dateObj == nil {
            inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let noSeconds = inputDateFormatter.date(from: timestamp)
            
            if noSeconds == nil {
                inputDateFormatter.dateFormat = "yyyy/MM/dd"
                let legacyDate = inputDateFormatter.date(from: timestamp)
                
                if legacyDate == nil {
                    print("Import::error Date could not be processed \(timestamp)")
                }
                
                return legacyDate!
            }
            
            return noSeconds!
        }
        
        return dateObj!
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)

        return paths[0]
    }
    
//    private func showDelete() -> Void {
//        isDeleteConfirmationPresented = true
//    }
//    
//    private func hideDelete() -> Void {
//        isDeleteConfirmationPresented = false
//    }
}

struct ImportPreview: PreviewProvider {
    static var previews: some View {
        Import().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
