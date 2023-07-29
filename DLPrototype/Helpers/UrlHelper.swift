//
//  UrlHelper.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-28.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public struct UrlParts {
    public var jid_double: Double? = 0.0
    public var jid_string: String = "0.0"
}

public final class UrlHelper {
    public var url: URL

    public init(url: URL) {
        self.url = url
    }

    public init(url: String) {
        if let validUrl = URL(string: url) {
            self.url = validUrl
        } else {
            self.url = URL(string: "https://apple.com")!
        }
    }

    static public func parts(of url: URL) -> UrlParts {
        let instance = UrlHelper(url: url)
        var jobId = ""

        if instance.isAsanaLink() {
            let id = instance.fromAsana()
            if id != nil {
                jobId = String(id!.suffix(6))
            }
        } else {
            jobId = String(url.absoluteString.suffix(6))
        }

        let defaultJid = 11.0

        return UrlParts(
            jid_double: Double(jobId) ?? defaultJid,
            jid_string: jobId
        )
    }

    static public func parts(of url: String) -> UrlParts {
        let instance = UrlHelper(url: url)
        var jobId = ""

        if instance.isAsanaLink() {
            let id = instance.fromAsana()
            if id != nil {
                jobId = String(id!.suffix(6))
            }
        } else {
            jobId = String(url.suffix(6))
        }

        let defaultJid = 11.0

        return UrlParts(
            jid_double: Double(jobId) ?? defaultJid,
            jid_string: jobId
        )
    }

    public func fromAsana() -> String? {
        let pattern = /https:\/\/app.asana.com\/0\/\d+\/(\d+)[\/f]?/

        if let match = url.absoluteString.firstMatch(of: pattern) {
            return String(match.1)
        }

        return nil
    }

    private func isAsanaLink() -> Bool {
        let pattern = /^https:\/\/app.asana.com/

        return url.absoluteString.contains(pattern)
    }
}
