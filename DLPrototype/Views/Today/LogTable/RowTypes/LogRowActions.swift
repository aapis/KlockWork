//
//  LogRowActions.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct LogRowActions: View, Identifiable {
    public var entry: Entry
    public var colour: Color
    public var index: Array<Entry>.Index?
    public var id = UUID()
    
    @Binding public var isEditing: Bool
    @Binding public var isDeleting: Bool
    
    @State private var editedField: String = ""
    @State private var editedFieldValue: String = ""
    
    var body: some View {
        // no special mode engaged
        HStack {
            Button(action: edit) {
                Image(systemName: "pencil")
            }
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(colour)
            
            Button(action: copy) {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(colour)
            
            Button(action: delete) {
                Image(systemName: "nosign")
            }
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(colour)
        }
        .opacity(isEditing || isDeleting ? 0 : 1)
        
        // view when you are editing
        HStack {
            Button(action: save) {
                Text("Save")
                    .foregroundColor(colour)
            }
        }
        .opacity(isEditing ? 1 : 0)
        
        // view when you are deleting
        HStack {
            Button(action: purge) {
                Text("Delete")
                    .foregroundColor(colour)
            }
        }
        .opacity(isDeleting ? 1 : 0)
    }
    
    private func edit() -> Void {
        print("editing")
        isEditing = true
    }
    
    private func save() -> Void {
        print("saving")
        isEditing = false
        
        print(entry.message)
    }
    
    private func copy() -> Void {
        let pasteBoard = NSPasteboard.general
        let data = "\(entry.timestamp) - \(entry.job) - \(entry.message)"
        
        pasteBoard.clearContents()
        pasteBoard.setString(data, forType: .string)
    }
    
    private func delete() -> Void {
        print("deleting!")
        isDeleting = true
    }
    
    private func purge() -> Void {
        print("really deleting!!!")
        isDeleting = false
    }
}

struct LogTableRowActionsPreview: PreviewProvider {
    static var previews: some View {
        let entry = Entry(timestamp: "2023-01-01 19:48", job: "88888", message: "Hello, world")
        let pView = LogRow(entry: entry, index: 0, colour: Color.red)
        
        LogRowActions(entry: entry, colour: Color.red, index: pView.index, isEditing: pView.$isEditing, isDeleting: pView.$isDeleting)
        LogRowActions(entry: entry, colour: Color.red, index: pView.index, isEditing: pView.$isEditing, isDeleting: pView.$isDeleting)
    }
}
