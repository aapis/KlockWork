//
//  JobPicker.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct JobPicker: View {
    public var onChange: (Int, String?) -> Void
    public var transparent: Bool? = false
    public var labelText: String?
    public var showLabel: Bool? = false
    
    @Environment(\.managedObjectContext) var moc
    
    private var pickerItems: [CustomPickerItem] {
        var items: [CustomPickerItem] = [CustomPickerItem(title: "Choose a job", tag: 0)]
        let projects = CoreDataProjects(moc: moc).alive()
        
        for project in projects {
            if project.jobs!.count > 0 {
                items.append(CustomPickerItem(title: "Project: \(project.name!)", tag: Int(-1)))
                
                if project.jobs != nil {
                    let unsorted = project.jobs!.allObjects as! [Job]
                    var jobs = unsorted.sorted(by: ({$0.jid > $1.jid}))
                    jobs.removeAll(where: {($0.project?.configuration?.ignoredJobs!.contains($0.jid.string))!})                    
                    
                    for job in jobs {
                        items.append(CustomPickerItem(title: " - \(job.jid.string)", tag: Int(job.jid)))
                    }
                }
            }
        }
        
        return items
    }
    
    var body: some View {
        FancyPicker(onChange: onChange, items: pickerItems, transparent: transparent, labelText: labelText, showLabel: showLabel)
    }
}
