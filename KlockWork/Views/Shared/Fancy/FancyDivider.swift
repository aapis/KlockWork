//
//  FancyDivider.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct FancyDivider: View {
    public var height: CGFloat? = 20
    var body: some View {
        Divider()
            .frame(height: height!)
            .overlay(.clear)
            .foregroundColor(.clear)
    }
}
