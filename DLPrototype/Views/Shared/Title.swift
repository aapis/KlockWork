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
    public var image: String?
    public var showLabel: Bool? = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                if let img = image {
                    Text(Image(systemName: img))
                        .font(Theme.fontTitle)
                }

                if showLabel! {
                    Text(text)
                        .font(Theme.fontTitle)
                }
            }
            .padding(3)
            .background(.pink)
            .foregroundColor(.black)
        }
    }
}
