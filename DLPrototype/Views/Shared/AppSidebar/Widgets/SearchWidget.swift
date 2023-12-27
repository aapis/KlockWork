//
//  SearchWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-26.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct SearchWidget: View {
    @State private var isLoading: Bool = false

    var body: some View {
        if isLoading {
            WidgetLoading()
        } else {
            WidgetBody()
        }
    }
}

extension SearchWidget {
    struct WidgetBody: View {
        var body: some View {
            VStack {
                Text("hi")
            }
        }
    }
}
