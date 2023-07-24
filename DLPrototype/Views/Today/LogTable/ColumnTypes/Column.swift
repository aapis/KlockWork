//
//  Column.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public enum ColumnType {
    case timestamp, job, standard, index
}

struct Column: View {
    public var type: ColumnType = .standard
    public var colour: Color
    public var textColour: Color
    public var index: Array<Entry>.Index?
    public var alignment: Alignment = .leading
    public var url: URL?
    public var job: Job?
    
    @Binding public var text: String

    @EnvironmentObject public var jm: CoreDataJob
    
    @AppStorage("tigerStriped") private var tigerStriped = false
    
    var body: some View {
        Group {
            ZStack(alignment: alignment) {
                colour

                if type == .timestamp {
                    Text(formatted())
                        .padding(10)
                        .foregroundColor(textColour)
                } else {
                    if type == .job {
                        HStack {
                            if job != nil {
                                NavigationLink {
                                    JobDashboard(defaultSelectedJob: job!.jid)
                                        .environmentObject(jm)
                                } label: {
                                    Text(text.replacingOccurrences(of: ".0", with: ""))
                                        .foregroundColor(colour.isBright() ? Color.black : Color.white)
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
                            }

                            // TODO: move to new statuses column
                            //                                if job!.shredable {
                            //                                    Image(systemName: "dollarsign.circle")
                            //                                        .foregroundColor(colour.isBright() ? Color.black : Color.white)
                            //                                        .help("Eligible for SR&ED")
                            //                                }
                        }
                        .padding([.leading, .trailing], 10)
                    } else if type == .index {
                        Text(text)
                            .foregroundColor(textColour)
                            .help(text)
                    } else {
                        Text(text)
                            .padding(10)
                            .foregroundColor(textColour)
                            .help(text)
                    }
                }
            }
        }
    }

    private func formatted() -> String {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.timeZone = TimeZone.autoupdatingCurrent
        inputDateFormatter.locale = NSLocale.current
        inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let inputDate = inputDateFormatter.date(from: text)

        if inputDate == nil {
            return "Invalid date"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = inputDateFormatter.timeZone
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "h:mm a"

        return dateFormatter.string(from: inputDate!)
    }
}
