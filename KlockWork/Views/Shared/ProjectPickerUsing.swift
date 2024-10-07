//
//  ProjectPickerUsing.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-20.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import Combine

enum PickerSize {
    case small, large
}

struct ProjectPickerUsing: View {
    public var onChange: ((String, String?) -> Void)? = nil
    public var onChangeLarge: ((Project, String?) -> Void)? = nil // @TODO: refactor, don't like this multiple callback func def thing
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
        var items: [CustomPickerItem] = [CustomPickerItem(title: "Choose from Projects", tag: 0)]
        let companies = CoreDataCompanies(moc: moc).alive()

        for company in companies.sorted(by: {$0.name! < $1.name!}) {
            if company.name != nil && company.projects?.count ?? 0 > 0 {
                items.append(
                    CustomPickerItem(
                        title: company.name!,
                        tag: Int(company.pid),
                        disabled: true
                    )
                )

                if let projects = company.projects {
                    for project in (projects.allObjects as! [Project]).sorted(by: {$0.name! < $1.name!}) {
                        items.append(
                            CustomPickerItem(
                                title: " - \(project.name!)",
                                tag: Int(project.pid),
                                project: project
                            )
                        )
                    }
                }
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
                            onChange: onChangeSmallWidget,
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
                            onChange: onChangeLargeWidget,
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
    /// Sets the selected picker item if one was passed to the view
    /// - Returns: Void
    private func onLoad() -> Void {
        if let item = pickerItems.first(where: {$0.tag == defaultSelection}) {
            selectedId = item.tag
        }
    }
    
    /// Callback that fires when a PickerSize.small widget changes selected value
    /// - Parameters:
    ///   - selected: Index value for the selected CustomPickerItem
    ///   - sender: Optional sender information
    /// - Returns: Void
    private func onChangeSmallWidget(selected: Int, sender: String?) -> Void {
        if let item = pickerItems.filter({$0.tag == selected}).first {
            projectName = item.title.replacingOccurrences(of: " - ", with: "")
        }

        selectedId = selected

        if let selectedJob = CoreDataProjects(moc: moc).byId(Int64(exactly: selected)!) {
            idFieldColour = Color.fromStored(selectedJob.colour ?? Theme.rowColourAsDouble)
            idFieldTextColour = idFieldColour.isBright() ? Color.black : Color.white
        } else {
            idFieldColour = Color.clear
            idFieldTextColour = Color.white
        }

        if let ocs = onChange {
            ocs(projectName, sender)
        }
    }
    
    /// Callback that fires when a PickerSize.large widget changes selected value
    /// - Parameter project: NSManagedObject
    /// - Returns: Void
    private func onChangeLargeWidget(selected: Int, sender: String?) -> Void {
        if let ocl = onChangeLarge {
            if let item = pickerItems.first(where: {$0.tag == selected}) {
                if item.project != nil {
                    ocl(item.project!, sender)
                }
            }
        }
    }

    private func resetUi() -> Void {
        idFieldColour = Color.clear
        idFieldTextColour = Color.white
    }
}
