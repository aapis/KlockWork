//
//  Entry.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation

struct Entry: Identifiable, Equatable {
    let timestamp: String
    var job: String = ""
    let message: String
    var url: String = ""
    let id = UUID()
    
    init(timestamp: String, job: String, message: String) {
        self.timestamp = timestamp
        self.job = job
        self.message = message
        self.url = ""
    }
    
    init(timestamp: String, url: String, message: String) {
        self.timestamp = timestamp
        self.url = url
        self.job = ""
        self.message = message
        
        setJobFromUrl()
    }
    
    mutating private func setJobFromUrl() -> Void {
        job = String(url.suffix(5))
    }
}
