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
    @State private var datePickerItems: [CustomPickerItem] = []
    @State private var pickerSelection: Int = 0
    @State private var highlighted: Bool = false

    @AppStorage("today.numPastDates") public var numPastDates: Int = 20
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var nav: Navigation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                .opacity(0.3)
                .blendMode(.softLight)
                .frame(height: 20)

            HStack(alignment: .center) {
                ViewModeSelector()
                    .padding(6)
                    .background(Theme.textBackground)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                UI.Pagination.Widget()
                Button(action: export, label: {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.down.to.line")
                        Text("Export")
                    }
                    .padding(6)
                    .background(Theme.textBackground)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                })
                .buttonStyle(.plain)
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .help("Export this view")
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
