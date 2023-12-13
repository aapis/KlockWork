//
//  CompanyPicker.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import Combine

struct CompanyPicker: View {
    public var onChange: (Int, String?) -> Void
    public var selected: Int = 0
    public var transparent: Bool? = false
    public var labelText: String?
    public var showLabel: Bool? = false

    @State private var idFieldColour: Color = Color.clear
    @State private var idFieldTextColour: Color = Color.white
    @State private var selectedId: String = ""
    @State private var projectName: String = ""

    @Environment(\.managedObjectContext) var moc

    private var pickerItems: [CustomPickerItem] {
        var items: [CustomPickerItem] = [CustomPickerItem(title: "Not set", tag: 0)]
        let companies = CoreDataCompanies(moc: moc).alive()

        for company in companies {
            if company.name != nil {
                items.append(CustomPickerItem(title: company.name!, tag: Int(company.pid)))
            }
        }

        return items
    }

    var body: some View {
        HStack(spacing: 5) {
            Text("Company: ")
            FancyPicker(
                onChange: onChange,
                items: pickerItems,
                transparent: transparent,
                labelText: labelText,
                showLabel: showLabel,
                defaultSelected: selected
            )
        }
    }
}
