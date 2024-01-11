//
//  ProjectPickerUsing.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-20.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import Combine

enum PickerSize {
    case small, large
}

struct ProjectPickerUsing: View {
    public var onChange: (String, String?) -> Void
    public var onChangeLarge: ((Int, String?) -> Void)? = nil // @TODO: refactor
    public var transparent: Bool? = false
    public var labelText: String?
    public var showLabel: Bool? = false
    public var size: PickerSize = .small
    public var defaultSelection: Int = 0

    @Binding public var displayName: String
    @State private var idFieldColour: Color = Color.clear
    @State private var idFieldTextColour: Color = Color.white
    @State private var selectedId: Int = 0
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
                if size == .small {
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
                        FancyPicker(
                            onChange: pickerChange,
                            items: pickerItems,
                            transparent: transparent,
                            labelText: labelText,
                            showLabel: showLabel,
                            defaultSelected: selectedId,
                            size: size
                        )
                    }
                    .padding([.leading], 150)
                } else {
                    HStack {
                        FancyPicker(
                            onChange: pickerChange,
                            items: pickerItems,
                            transparent: transparent,
                            labelText: labelText,
                            showLabel: showLabel,
                            defaultSelected: defaultSelection,
                            size: size
                        )
                    }
                    .padding()
                    .border(idFieldColour == Color.clear ? Color.black.opacity(0.1) : Color.clear, width: 2)
                }
            }
        }
        .frame(width: size == .small ? 450 : nil, height: 40)
        .onAppear(perform: onLoad)
    }
}

extension ProjectPickerUsing {
    private func onLoad() -> Void {
        if let item = pickerItems.first(where: {$0.tag == defaultSelection}) {
            selectedId = item.tag
        }
    }
    
    private func pickerChange(selected: Int, sender: String?) -> Void {
        if size == .small {
            if let item = pickerItems.filter({$0.tag == selected}).first {
                projectName = item.title.replacingOccurrences(of: " - ", with: "")
            }
            
            selectedId = selected
            
            if let selectedJob = CoreDataProjects(moc: moc).byId(Int(exactly: selected)!) {
                idFieldColour = Color.fromStored(selectedJob.colour ?? Theme.rowColourAsDouble)
                idFieldTextColour = idFieldColour.isBright() ? Color.black : Color.white
            } else {
                idFieldColour = Color.clear
                idFieldTextColour = Color.white
            }
            
            onChange(projectName, sender)
        } else if size == .large {
            if let ocl = onChangeLarge {
                ocl(selected, sender)
            }
        }
    }

    private func resetUi() -> Void {
        idFieldColour = Color.clear
        idFieldTextColour = Color.white
    }
}
