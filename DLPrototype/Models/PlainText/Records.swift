//
//  Records.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2022-04-08.
//  Copyright © 2022 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

class Records {
    private var records: [String] = []
    
    init() {
        records = readFile("Daily.log")
    }
    
    public func rowsContain(term: String) -> [String] {
        var results: [String] = []
        
        for record in records {
            if record.contains(term) {
                results.append(record)
            }
        }
        
        return results
    }
    
    public func rowsStartsWith(term: String) -> [String] {
        var results: [String] = []
        
        for record in records {
            if record.starts(with: term) {
                results.append(record)
            }
        }
        
        return results
    }

    private func readFile(_ fileName: String) -> [String] {
        var lines: [String] = []

        let log = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if let logLines = try? String(contentsOf: log) {
            for line in logLines.components(separatedBy: .newlines) {
                lines.append(line)
            }
        }
        
        return lines
    }
    
//    private func startsWithOld(term: String) -> [String] {
//        var lines: [String] = []
//
//        let log = getDocumentsDirectory().appendingPathComponent("Daily.log")
//
//        if let logLines = try? String(contentsOf: log) {
//            for line in logLines.components(separatedBy: .newlines) {
//                if line.starts(with: term) {
//                    lines.append(line)
//                }
//            }
//        }
//
//        return lines
//    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
}
