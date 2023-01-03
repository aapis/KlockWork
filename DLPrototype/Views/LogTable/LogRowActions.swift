//
//  LogRowActions.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct LogRowActions: View, Identifiable {
    public var id = UUID()
    
    // TODO: this specific view causes perf problems in Add
    // TODO: this specific view causes different perf problems in Search
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "nosign")
            }

            Button(action: {}) {
                Image(systemName: "doc.on.doc")
            }
        }
    }
}

struct LogTableRowActionsPreview: PreviewProvider {
    static var previews: some View {
        LogRowActions()
    }
}
