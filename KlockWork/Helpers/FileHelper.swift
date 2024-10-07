//
//  FileHelper.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation

public final class FileHelper {
    static public func readFile(_ fileName: String) -> [String] {
        var lines: [String] = []
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        if paths.isEmpty {
            return []
        }

        let log = paths.first!.appendingPathComponent(fileName)
        
        if let logLines = try? String(contentsOf: log) {
            for line in logLines.components(separatedBy: "\n") {
                lines.append(line)
            }
        }
        
        return lines
    }
}
