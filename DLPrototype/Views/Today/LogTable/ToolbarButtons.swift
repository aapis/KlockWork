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
    @Binding public var showSearch: Bool
    @Binding public var searchText: String
    @Binding public var selectedDate: Date
    @Binding public var records: [LogRecord]
    
    @State private var datePickerItems: [CustomPickerItem] = []
    @State private var pickerSelection: Int = 0
    
    private let numDatesInPast: Int = 20
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        HStack {
            // TODO: coming back soon
//            FancyButton(text: "Previous day", action: previous, icon: "chevron.left", transparent: true, showLabel: false)
//                .frame(maxHeight: 20)
            FancyPicker(onChange: change, items: datePickerItems)
                .onAppear(perform: {
                    datePickerItems = CustomPickerItem.listFrom(DateHelper.datesBeforeToday(numDays: numDatesInPast)) // TODO: add dateFormat: "EEEEEE - yyyy-MM-dd" 
                })
            // TODO: coming back soon
//            FancyButton(text: "Next day", action: next, icon: "chevron.right", transparent: true, showLabel: false)
//                .frame(maxHeight: 20)
            
            // TODO: this one is coming back
//            Button(action: reload, label: {
//                Image(systemName: "arrow.counterclockwise")
//            })
//            .help("Reload data")
//            .keyboardShortcut("r")
//            .buttonStyle(.borderless)
//            .foregroundColor(Color.white)
            
            Button(action: export, label: {
                Image(systemName: "arrow.down.to.line")
            })
            .buttonStyle(.borderless)
            .keyboardShortcut("c")
            .help("Export this view")
            .foregroundColor(Color.white)
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            
            Spacer()
            
            Button(action: toggleSearch, label: {
                Image(systemName: "magnifyingglass")
            })
            .help("Toggle search")
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            
            Button(action: toggleSidebar, label: {
                Image(systemName: "sidebar.right")
            })
            .help("Toggle sidebar")
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }.padding(8)
    }
    
    private func change(selected: Int, sender: String?) -> Void {
        let item = datePickerItems[selected].title
        
        pickerSelection = selected
        selectedDate = DateHelper.date(item) ?? Date()
    }
    
    private func toggleSidebar() -> Void {
        withAnimation(.easeInOut) {
            showSidebar.toggle()
        }
    }
    
    private func toggleSearch() -> Void {
        withAnimation(.easeInOut) {
            showSearch.toggle()
        }
    }
    
    private func reload() -> Void {
        //
    }
    
    private func previous() -> Void {
        if pickerSelection <= numDatesInPast {
            pickerSelection += 1
            
            let item = datePickerItems[pickerSelection].title

            print("Fancy::prev.selection \(selectedDate)")
            selectedDate = DateHelper.date(item) ?? Date()
        }
    }
    
    private func next() -> Void {
        if pickerSelection > 0 {
            pickerSelection -= 1
            let item = datePickerItems[pickerSelection].title
                
            print("Fancy::next.selection \(selectedDate)")
            selectedDate = DateHelper.date(item) ?? Date()
        }
    }
    
    private func export() -> Void {
        var pasteboardContents = ""
        
        for record in records {
            if record.job != nil {
                let ignoredJobs = record.job!.project?.configuration?.ignoredJobs
                let cleaned = CoreDataProjectConfiguration.applyBannedWordsTo(record)
                
                if ignoredJobs != nil {
                    if !ignoredJobs!.contains(record.job!.jid.string) {
                        let url = record.job!.uri
                        
                        if url != nil {
                            pasteboardContents += "\(record.timestamp!) - \(record.job!.uri!.absoluteString) - \(cleaned.message!)\n"
                        } else {
                            pasteboardContents += "\(record.timestamp!) - \(record.job!.jid.string) - \(cleaned.message!)\n"
                        }
                    }
                }
            }
        }
        
        ClipboardHelper.copy(pasteboardContents)
    }
    
    private func toStringList(_ items: [Entry]) -> String {
        var out = ""
        
        for item in items {
            out += item.toString() + "\n"
        }
        
        return out
    }
}
