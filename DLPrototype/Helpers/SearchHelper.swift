//
//  SearchHelper.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public final class SearchHelper {
    public var bucket: [LogTask] = [] // TODO: make this class+prop generic
    public var fields: [String] = []
    
    public init(bucket: FetchedResults<LogTask>) {
        self.bucket = Array(bucket)
    }
    
    public func exec(_ searchText: Binding<String>) -> [LogTask] {
        return bucket.filter({
            matches(searchText, fields: [$0.content ?? "", $0.owner!.jid.string])
        })
    }
    
    private func matches(_ searchText: Binding<String>, fields: [String]) -> Bool {
        do {
            let caseInsensitiveTerm = try Regex(searchText.wrappedValue).ignoresCase()
            
            return fields.filter({
                $0.contains(caseInsensitiveTerm)
            }).count > 0
        } catch {
            print("Searching LogTable::search(term: String) - Unable to process string \(error.localizedDescription)")
        }
        
        return false
    }
}
