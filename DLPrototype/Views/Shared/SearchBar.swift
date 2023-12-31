//
//  SearchBar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    @Binding public var text: String
    
    public var disabled: Bool = false
    public var placeholder: String? = "Search..."
    public var onSubmit: (() -> Void)? = nil
    public var onReset: (() -> Void)? = nil
    // @TODO: this will remember the search text between pages, but I think instead I need some kind of search history
//    @AppStorage("shared.searchbar") private var text: String = ""
    
    var body: some View {
        GridRow {
            HStack {
                ZStack(alignment: .trailing) {
                    FancyTextField(placeholder: placeholder!, lineLimit: 1, onSubmit: onSubmit, disabled: disabled, text: $text)
                    
                    Spacer()
                    
                    if text.count > 0 {
                        FancyButtonv2(
                            text: "Reset",
                            action: reset,
                            icon: "xmark",
                            showLabel: false,
                            size: .tiny,
                            type: .white
                        )
                        .padding([.trailing])
                    }
                }
            }
        }
    }
}

extension SearchBar {
    private func reset() -> Void {
        text = ""

        if onReset != nil {
            onReset!()
        }
    }
}
