//
//  Entry.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

public struct Entry: Identifiable, Equatable {
    public let timestamp: String
    public var job: String = ""
    public var message: String
    public var url: String = ""
    public var colour: Color
    public var jobObject: Job? = nil
    public var dateObject: Date? = nil
    public let id = UUID()
    
    public init(timestamp: String, job: String, message: String) {
        self.timestamp = timestamp
        self.job = job
        self.message = message
        self.url = ""
        self.colour = Color.gray.opacity(0.2)
    }
    
    public init(timestamp: String, job: String, message: String, colour: Color) {
        self.timestamp = timestamp
        self.job = job
        self.message = message
        self.url = ""
        self.colour = colour
    }
    
    public init(timestamp: String, url: String, message: String) {
        self.timestamp = timestamp
        self.url = url
        self.job = ""
        self.message = message
        self.colour = Color.gray.opacity(0.2)
        
        setJobFromUrl()
    }
    
    public init(timestamp: String, job: Job, message: String) {
        self.timestamp = timestamp
        self.url = ""
        self.job = job.jid.string
        self.message = message
        self.colour = Color.gray.opacity(0.2)
        self.jobObject = job
    }
    
    public init(timestamp: Date, job: Job, message: String) {
        self.dateObject = timestamp
        self.timestamp = DateHelper.longDate(dateObject!)
        self.url = ""
        self.job = job.jid.string
        self.message = message
        self.colour = Color.gray.opacity(0.2)
        self.jobObject = job
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
}
