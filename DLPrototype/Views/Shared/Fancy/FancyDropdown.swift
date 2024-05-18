//
//  FancyDropdown.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-05-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

enum FilterAction {
    case select, deselect
}

struct FancyDropdown: View {
    public var label: String
    public var icon: String = "chevron.right"
    public var items: [String] = []
    public var onChange: (String, FilterAction) -> Void = {_, _ in }

    @State private var showChildren: Bool = false
    @State private var selected: String = ""

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        HStack(alignment: .center, spacing: 1) {
            Button {
                showChildren.toggle()
            } label: {
                HStack(spacing: 5) {
                    Text(label)
                    Image(systemName: showChildren ? "xmark" : icon)
                }
                .padding(10)
                .background(.white.opacity(0.15))
                .mask(Capsule())
            }
            .buttonStyle(.plain)
            .useDefaultHover({_ in})

            if showChildren {
                HStack {
                    ForEach(items, id: \.self) { itemLabel in
                        Button {
                            onChange(itemLabel, selected != itemLabel ? .select : .deselect)

                            if selected == itemLabel {
                                selected = ""
                            } else {
                                selected = itemLabel
                            }

                            showChildren = false
                        } label: {
                            HStack {
                                Text(String(itemLabel))

                                if selected == itemLabel {
                                    Image(systemName: "xmark")
                                }
                            }
                            .padding(10)
                            .background(Theme.textBackground)
                            .mask(Capsule())
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({_ in})
                    }
                }
                .padding(.leading, 5)
            }
        }
    }
}

#Preview {
    FancyDropdown(label: "Type", items: ["log", "conf"])
}
