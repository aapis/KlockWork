//
//  ProjectPickerUsing.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-20.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import Combine

struct ProjectPickerUsing: View {
    public var onChange: (String, String?) -> Void
    public var transparent: Bool? = false
    public var labelText: String?
    public var showLabel: Bool? = false

    @Binding public var displayName: String
    @State private var idFieldColour: Color = Color.clear
    @State private var idFieldTextColour: Color = Color.white
    @State private var selectedId: String = ""
    @State private var projectName: String = ""
    
    @Environment(\.managedObjectContext) var moc
    
    private var pickerItems: [CustomPickerItem] {
        var items: [CustomPickerItem] = [CustomPickerItem(title: "Choose a project", tag: 0)]
        let projects = CoreDataProjects(moc: moc).alive()
        
        for project in projects {
            if project.name != nil {
                items.append(CustomPickerItem(title: " - \(project.name!)", tag: Int(project.pid)))
            }
        }
        
        return items
    }
    
    var body: some View {
        HStack {
            ZStack {
                FancyTextField(
                    placeholder: "Project name",
                    lineLimit: 1,
                    onSubmit: {},
                    fgColour: idFieldTextColour,
                    bgColour: idFieldColour,
                    text: $projectName
                )
                .border(idFieldColour == Color.clear ? Color.black.opacity(0.1) : Color.clear, width: 2)
                
                HStack {
//                    if !id.isEmpty {
//                        FancyButton(text: "Reset", action: resetUi, icon: "xmark", showLabel: false)
//                    }
                    FancyPicker(onChange: pickerChange, items: pickerItems, transparent: transparent, labelText: labelText, showLabel: showLabel)
                }
                .padding([.leading], 150)
            }
        }
        .frame(width: 450, height: 40)
        .onAppear(perform: onAppear)
    }
    
    private func pickerChange(selected: Int, sender: String?) -> Void {
        if let item = pickerItems.filter({$0.tag == selected}).first {
            projectName = item.title.replacingOccurrences(of: " - ", with: "")
        }

        selectedId = String(selected)
        
        if let selectedJob = CoreDataProjects(moc: moc).byId(Int(exactly: selected)!) {
            idFieldColour = Color.fromStored(selectedJob.colour ?? Theme.rowColourAsDouble)
            idFieldTextColour = idFieldColour.isBright() ? Color.black : Color.white
        } else {
            idFieldColour = Color.clear
            idFieldTextColour = Color.white
        }
        
        onChange(projectName, sender)
    }
    
    private func onAppear() -> Void {
        // TODO: this is borked now, fix it
//        if !id.isEmpty {
//            let pid = (id as NSString).integerValue
//            print("JERB pid \(pid)")
//
//            pickerChange(selected: pid, sender: "")
//        }
    }
    
    private func resetUi() -> Void {
        idFieldColour = Color.clear
        idFieldTextColour = Color.white
    }
}
