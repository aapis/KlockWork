//
//  JobRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct JobRow: View {
    public var job: Job
    public var colour: Color
    
    var body: some View {
        HStack(spacing: 1) {
            project
            
            ZStack(alignment: .leading) {
                colour
                
                HStack {
                    NavigationLink {
                        JobDashboard(defaultSelectedJob: job.jid)
                    } label: {
                        Text(job.jid.string)
                            .foregroundColor(colour.isBright() ? Color.black : Color.white)
                            .padding([.leading, .trailing], 10)
                            .onHover { inside in
                                if inside {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                            .help("Edit job")
                    }
                    .buttonStyle(.borderless)
                    .underline()
                    
                    if job.uri != nil {
                        Link(destination: job.uri!, label: {
                            Image(systemName: "link")
                                .foregroundColor(colour.isBright() ? Color.black : Color.white)
                                .onHover { inside in
                                    if inside {
                                        NSCursor.pointingHand.push()
                                    } else {
                                        NSCursor.pop()
                                    }
                                }
                                .help("Visit job URL on the web")
                        })
                    }
                }
            }.frame(width: 200)
            
            ZStack(alignment: .leading) {
                colour
                
                Text(colour.description.debugDescription)
                    .padding(10)
                    .foregroundColor(colour.isBright() ? Color.black : Color.white)
                    .contextMenu {
                        Button(action: {ClipboardHelper.copy("\(colour)".debugDescription)}, label: {
                            Text("Copy colour code")
                        })
                    }
            }
        }
    }
    
    @ViewBuilder var project: some View {
        Group {
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    if job.project != nil {
                        Color.fromStored(job.project!.colour ?? Theme.rowColourAsDouble)
                    } else {
                        Theme.rowColour
                    }
                }
            }
        }
        .frame(width: 5)
    }
}

//struct JobRowPreview: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            DetailsRow(key: "Linked row", value: "22", colour: Color.blue)
//            DetailsRow(key: "Standard row", value: "22", colour: Color.purple)
//        }
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
