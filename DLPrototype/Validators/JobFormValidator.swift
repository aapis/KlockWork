//
//  JobFormValidator.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-28.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public final class JobFormValidator {
    private var moc: NSManagedObjectContext

    public init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    public func validateJobId(_ jobId: String) -> (Bool, Bool) {
        if jobId.isEmpty {
            return (false, false)
        }

        if let doubleId = Double(jobId) {
            if let job = CoreDataJob(moc: moc).byId(doubleId) {
                return (false, job.jid == doubleId)
            }
        }

        return (true, false)
    }

    public func validateUrl(_ url: String) -> (Bool, Bool) {
        if !url.isEmpty {
            if url.starts(with: "https:") {
                if let uri = URL(string: url) {
                    if let job = CoreDataJob(moc: moc).byUrl(uri) {
                        return (false, job.uri! == uri)
                    }
                }
            } else {
                return (false, false)
            }
        }

        return (true, false)
    }

    public func onChangeCallback(jobFieldValue: String, valid: Binding<Bool>?, id: Binding<String>?) -> Void {
        let filtered = jobFieldValue.filter { "0123456789\\.".contains($0) }
        let (jobValid, isCurrent) = JobFormValidator(moc: moc).validateJobId(filtered)

        if isCurrent {
            valid?.wrappedValue = true
        } else {
            valid?.wrappedValue = jobValid
        }

        id?.wrappedValue = filtered
    }

    public func onChangeCallback(urlFieldValue: String, valid: Binding<Bool>?, id: Binding<String>?) -> Void {
        let (urlValid, isCurrent) = JobFormValidator(moc: moc).validateUrl(urlFieldValue)

        if isCurrent {
            valid?.wrappedValue = true
        } else {
            valid?.wrappedValue = urlValid
        }

        if valid != nil {
            if valid!.wrappedValue {
                if let newUrl = URL(string: urlFieldValue) {
                    id?.wrappedValue = UrlHelper.parts(of: newUrl).jid_string
                }
            }
        }
    }
}
