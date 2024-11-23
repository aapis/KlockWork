//
//  CSVFile.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-11-20.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

public struct CSVFileDocument: FileDocument {
    static public var readableContentTypes = [UTType.commaSeparatedText]

    var text = ""

    public init(initialText: String = "") {
        text = initialText
    }

    public init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
