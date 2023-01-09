//
//  Entry.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public struct Entry: Identifiable, Equatable {
    public let timestamp: String
    public var job: String = ""
    public let message: String
    public var url: String = ""
    public var colour: Color //= Color.gray.opacity(0.2)
    public let id = UUID()
    
    init(timestamp: String, job: String, message: String) {
        self.timestamp = timestamp
        self.job = job
        self.message = message
        self.url = ""
        self.colour = Color.gray.opacity(0.2)
    }
    
    init(timestamp: String, job: String, message: String, colour: Color) {
        self.timestamp = timestamp
        self.job = job
        self.message = message
        self.url = ""
        self.colour = colour
    }
    
    init(timestamp: String, url: String, message: String) {
        self.timestamp = timestamp
        self.url = url
        self.job = ""
        self.message = message
        self.colour = Color.gray.opacity(0.2)
        
        setJobFromUrl()
    }
    
    mutating public func setColour(_ colour: Color) -> Void {
        self.colour = colour
    }
    
    public func toString() -> String {
        return "\(timestamp) - \(job) - \(message)"
    }
    
    mutating private func setJobFromUrl() -> Void {
        job = String(url.suffix(5))
    }
    
    // TODO: this is INCOMPLETE and unused, finish implementation
    static public func listFrom(_ records: [String]) -> [Entry] {
//        let entry = Entry(timestamp: DateHelper.todayShort(), job: "11", message: "message")
//        
        var list: [Entry] = []
//        
//        for (i, rec) in records {
//            list.append(Entry(title: rec, tag: i))
//        }
//        
//        return list
//        return [entry]
        return list
    }
}
