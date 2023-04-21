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
    public var onChange: (Int, String?) -> Void
    public var transparent: Bool? = false
    public var labelText: String?
    public var showLabel: Bool? = false
    
    @Binding public var id: String
    @Binding public var displayName: String
    @State private var idFieldColour: Color = Color.clear
    @State private var idFieldTextColour: Color = Color.white
    @State private var selectedId: String = ""
    
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
                    text: displayName.isEmpty ? $id : $displayName
                )
                .border(idFieldColour == Color.clear ? Color.black.opacity(0.1) : Color.clear, width: 2)
                // TODO: remove? unnecessary?
//                .onChange(of: id) { _ in
//                    if id != "" {
//                        if let pid = Int(id) {
//                            pickerChange(selected: pid, sender: nil)
//                        }
//                    }
//                }
                HStack {
                    if !id.isEmpty {
                        FancyButton(text: "Reset", action: resetUi, icon: "xmark", showLabel: false)
                    }
                    FancyPicker(onChange: pickerChange, items: pickerItems, transparent: transparent, labelText: labelText, showLabel: showLabel)
                }
                .padding([.leading], 150)
            }
        }
        .frame(width: 450, height: 40)
        .onAppear(perform: onAppear)
    }
    
    private func pickerChange(selected: Int, sender: String?) -> Void {
        id = String(selected)
        selectedId = String(selected)
        let pm = CoreDataProjects(moc: moc)
        
        let s = pm.byId(selected)
        
        print("JERB pid changed \(id) \(Int(id))")
        
        if s != nil {
            print("JERB pid changed w/name \(id) \(s!.name)")
        } else {
            print("JERB s is nil for \(id)")
        }
        
        if let selectedJob = pm.byId(Int(id)!) {
            idFieldColour = Color.fromStored(selectedJob.colour ?? Theme.rowColourAsDouble)
            idFieldTextColour = idFieldColour.isBright() ? Color.black : Color.white
        } else {
            idFieldColour = Color.clear
            idFieldTextColour = Color.white
        }
        
        onChange(selected, "")
    }
    
    private func onAppear() -> Void {
        if !id.isEmpty {
            let pid = (id as NSString).integerValue
            print("JERB pid \(pid)")
            
            pickerChange(selected: pid, sender: "")
        }
    }
    
    private func resetUi() -> Void {
        id = ""
        idFieldColour = Color.clear
        idFieldTextColour = Color.white
    }
}
