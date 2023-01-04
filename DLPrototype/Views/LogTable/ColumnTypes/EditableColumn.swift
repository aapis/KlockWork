//
//  EditableColumn.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct EditableColumn: View {
    public var type: String
    public var entry: Entry
    public var colour: Color
    public var textColour: Color
    public var index: Array<Entry>.Index?
    
    @Binding public var isEditing: Bool
    @Binding public var isDeleting: Bool
    @Binding public var text: String    
    
    @AppStorage("tigerStriped") private var tigerStriped = false
    
    var body: some View {
        Group {
            ZStack(alignment: .leading) {
                colour
                if isEditing {
                    TextField(type, text: $text)
                        .lineLimit(5)
                        .disableAutocorrection(true)
                        .foregroundColor(textColour)
                } else {
                    if type == "timestamp" {
                        Text(formatted())
                            .padding(10)
                            .foregroundColor(textColour)
                    } else {
                        Text(text)
                            .padding(10)
                            .foregroundColor(textColour)
                    }
                        
                }
            }
        }
    }
    
    private func formatted() -> String {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.timeZone = TimeZone(abbreviation: "MST")
        inputDateFormatter.locale = NSLocale.current
        inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let inputDate = inputDateFormatter.date(from: text)
        
        if inputDate == nil {
            return "Invalid date"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "MST")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter.string(from: inputDate!)
    }
}
