//
//  FancyDivider.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyDivider: View {
    var body: some View {
        Divider()
            .frame(height: 20)
            .overlay(.clear)
            .foregroundColor(.clear)
    }
}
