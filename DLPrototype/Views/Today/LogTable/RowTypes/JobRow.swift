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
            ZStack(alignment: .leading) {
                colour

                if job.uri != nil {
                    Link(job.jid.string, destination: job.uri!.absoluteURL)
                        .padding(10)
                        .foregroundColor(colour.isBright() ? Color.black : Color.white)
                        .help("Open \(job.uri!.absoluteString)")
                        .underline()
                        .contextMenu {
                            Button(action: {ClipboardHelper.copy(job.uri!.absoluteString)}, label: {
                                Text("Copy link")
                            })
                        }
                        .onHover { inside in
                            if inside {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                } else {
                    Text(job.jid.string)
                        .padding(10)
                        .foregroundColor(colour.isBright() ? Color.black : Color.white)
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
