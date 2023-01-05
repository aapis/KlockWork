//
//  ActionButtons.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ToolbarButtons: View {
    @Binding public var selectedTab: Int
    @Binding public var isShowingAlert: Bool
    @Binding public var showSidebar: Bool
    @Binding public var searchText: String
    public var records: Records
    
    var body: some View {
        HStack {
            Button(action: reload, label: {
                Image(systemName: "arrow.counterclockwise")
            })
            .help("Reload data")
            .keyboardShortcut("r")
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            
            Button(action: {isShowingAlert = true; newDayAction() }, label: {
                Image(systemName: "sunrise")
            })
            .help("New day")
            .keyboardShortcut("n")
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            //                        .alert("It's a brand new day!", isPresented: $isPresented) {}
            
            Button(action: copyAll, label: {
                Image(systemName: "doc.on.doc")
            })
            .buttonStyle(.borderless)
            .keyboardShortcut("c")
            .help("Copy all rows")
            .foregroundColor(Color.white)
            
            Spacer()
            Button(action: toggleSidebar, label: {
                Image(systemName: "sidebar.right")
            })
            .help("Toggle sidebar")
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
        }.padding(8)
    }
    
    private func toggleSidebar() -> Void {
        withAnimation(.easeInOut) {
            showSidebar.toggle()
        }
    }
    
    private func reload() -> Void {
        records.reload()
    }
    
    private func newDayAction() -> Void {
        records.clear()
        records.logNewDay()
    }
    
    private func copyAll() -> Void {
        let pasteBoard = NSPasteboard.general
        var source: [Entry] = []
        
        if selectedTab == 0 {
            source = records.entries
        } else if selectedTab == 1 {
            source = records.sortByJob()
        } else if selectedTab == 2 {
            source = records.search(term: searchText)
        }
        
        let data = toStringList(source)
        
        pasteBoard.clearContents()
        pasteBoard.setString(data, forType: .string)
    }
    
    private func toStringList(_ items: [Entry]) -> String {
        var out = ""
        
        for item in items {
            out += item.toString() + "\n"
        }
        
        return out
    }
}
