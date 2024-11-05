//
//  FancyPicker.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-07.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct FancyPicker: View {
    @EnvironmentObject public var state: Navigation
    public var onChange: (Int, String?) -> Void
    public var items: [CustomPickerItem] = []
    public var transparent: Bool? = false
    public var labelText: String?
    public var showLabel: Bool? = false
    public var defaultSelected: Int = 0
    public var size: PickerSize = .large
    public var icon: String = "questionmark.app.fill"
    @State private var isDropdownOpen: Bool = false
    @State private var selection: Int = 0
    
    var body: some View {
        Group {
            if showLabel! {
                showWithLabel
            } else {
                showNoLabel
            }
        }
        .onAppear(perform: {
            selection = defaultSelected
        })
    }

    var showNoLabel: some View {
        VStack {
            HStack(spacing: 0) {
                if self.labelText == nil {
                    Image(systemName: self.icon)
                        .symbolRenderingMode(.hierarchical)
                        .font(.headline)
                        .foregroundStyle(self.state.session.job != nil ? self.state.session.job?.backgroundColor ?? .white : self.state.theme.tint)
                }
                Picker(labelText ?? "", selection: $selection) {
                    ForEach(items) { item in
                        Text(item.title)
                            .tag(item.tag)
                    }
                }
                .useDefaultHover({_ in})
                .frame(width: 150)
                .onChange(of: self.selection) {
                    onChange(self.selection, self.labelText)
                }
            }
        }
    }
    
    var showWithLabel: some View {
        VStack {
            Picker(labelText ?? "Picker", selection: $selection) {
                ForEach(items) { item in
                    Text(item.title)
                        .tag(item.tag)
                }
            }
            .useDefaultHover({_ in})
            .onChange(of: self.selection) {
                onChange(self.selection, self.labelText)
            }
        }
    }
}
