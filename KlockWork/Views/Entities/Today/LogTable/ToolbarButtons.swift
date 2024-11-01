//
//  ActionButtons.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct ToolbarButtons: View {
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var nav: Navigation
    @AppStorage("today.numPastDates") public var numPastDates: Int = 20
    public var records: [LogRecord]?
//    public var activities: [UI.GenericTimelineActivity]?
    @State private var datePickerItems: [CustomPickerItem] = []
    @State private var pickerSelection: Int = 0
    @State private var highlighted: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            self.nav.session.appPage.primaryColour
            LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                .opacity(0.3)
                .blendMode(.softLight)
                .frame(height: 20)

            HStack(alignment: .center) {
                UI.ViewModeSelector()
                    .padding(6)
                    .background(Theme.textBackground)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                UI.SortSelector()
                UI.Pagination.Widget()
                Button(action: export, label: {
                    HStack(spacing: 5) {
                        Image(systemName: "document.on.document.fill")
                        Text("Copy")
                    }
                    .padding(6)
                    .background(Theme.textBackground)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                })
                .buttonStyle(.plain)
                .keyboardShortcut("c", modifiers: [.control, .shift])
                .help("Copy view data to clipboard")
                .useDefaultHover({ hover in self.highlighted = hover})
                Spacer()
            }
            .padding(8)
        }
    }
    
    private func change(selected: Int, sender: String?) -> Void {
        let item = datePickerItems[selected].title
        
        pickerSelection = selected
        nav.session.date = DateHelper.date(item) ?? Date()
    }
    
    private func toggleSearch() -> Void {
        nav.session.toolbar.showSearch.toggle()
    }
    
    /// Copy data to clipboard
    /// - Returns: Void
    private func export() -> Void {
        if let records = self.records {
            ClipboardHelper.copy(
                CoreDataRecords(moc: self.nav.moc).createExportableRecordsFrom(records)
            )
        }
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
