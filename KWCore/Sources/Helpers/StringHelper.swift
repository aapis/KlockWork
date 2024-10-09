//
//  StringHelper.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public final class StringHelper {
    static public func abbreviate(_ data: String) -> String {
        let letters = data.split(separator: " ").map {$0.first!}

        // get the first 3 characters if there's only one word
        if letters.count == 1 {
            return String(data.prefix(4)).uppercased()
        }

        return String(letters).uppercased()
    }
    
    static func titleFromContent(from raw: String) -> String {
        if raw.starts(with: "#") {
            return raw.replacingOccurrences(of: "# ", with: "")
        }
        
        return ""
    }

    /// Converts a passed object into title text containing either a short or long string representing the consumed object
    /// - Parameter entity: NSManagedObject
    /// - Parameter max Int 30 by default
    /// - Returns: Void
    static public func titleFrom(_ entity: NSManagedObject?, max: Int = 30) -> String {
        if entity == nil {
            return ""
        }

        switch entity {
        case is Company:
            if let company = entity as? Company {
                if let title = company.name {
                    if title.count > max {
                        return company.abbreviation ?? "XXX"
                    } else {
                        return title
                    }
                }
            }
        case is Project:
            if let project = entity as? Project {
                if let title = project.name {
                    if title.count > max {
                        return project.abbreviation ?? "YYY"
                    } else {
                        return title
                    }
                }
            }
        case is Job:
            if let job = entity as? Job {
                if let title = job.title {
                    if title.count > max {
                        return job.jid.string
                    } else {
                        return title
                    }
                }
            }
        default:
            return ""
        }

        return ""
    }
}
