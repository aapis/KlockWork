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
//    @Binding public var selectedTab: Int
//    @Binding public var isShowingAlert: Bool
//    @Binding public var showSearch: Bool
//    @Binding public var searchText: String
//    @Binding public var selectedDate: Date
//    @Binding public var records: [LogRecord]
//    @Binding public var viewMode: ViewMode
    
    @State private var datePickerItems: [CustomPickerItem] = []
    @State private var pickerSelection: Int = 0
    
    @AppStorage("today.numPastDates") public var numPastDates: Int = 20
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var nav: Navigation
    
    var body: some View {
        HStack {
            ViewModeSelector()
            
            Button(action: export, label: {
                Image(systemName: "arrow.down.to.line")
            })
            .buttonStyle(.borderless)
            .keyboardShortcut("c", modifiers: [.command, .shift])
            .help("Export this view")
            .foregroundColor(Color.white)
            .useDefaultHover({_ in})
            
            Spacer()
            
            Button(action: toggleSearch, label: {
                Image(systemName: "magnifyingglass")
            })
            .help("Toggle search")
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .useDefaultHover({_ in})
        }.padding(8)
    }
    
    private func change(selected: Int, sender: String?) -> Void {
        let item = datePickerItems[selected].title
        
        pickerSelection = selected
        nav.session.date = DateHelper.date(item) ?? Date()
    }
    
    private func toggleSearch() -> Void {
        withAnimation(.easeInOut) {
            nav.session.toolbar.showSearch.toggle()
        }
    }
    
    private func export() -> Void {
        // @TODO: fix
//        ClipboardHelper.copy(
//            CoreDataRecords(moc: moc).createExportableRecordsFrom(records)
//        )
    }
    
    private func viewAsPlain() -> Void {
        nav.session.toolbar.mode = .plain
    }
    
    private func toStringList(_ items: [Entry]) -> String {
        var out = ""
        
        for item in items {
            out += item.toString() + "\n"
        }
        
        return out
    }
}
