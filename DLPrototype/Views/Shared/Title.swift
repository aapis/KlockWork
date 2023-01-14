//
//  Title.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Title: View {
    public var text: String
    public var image: String
    public var showLabel: Bool? = true
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(Image(systemName: image))
                .font(Theme.fontTitle)
            
            if showLabel! {
                Text(text)
                    .font(Theme.fontTitle)
            }
        }
    }
}
