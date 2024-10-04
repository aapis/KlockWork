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
    public var imageAsImage: Image?
    public var showLabel: Bool? = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                if let img = image {
                    Image(systemName: img)
                        .symbolRenderingMode(.hierarchical)
                } else if let iai = imageAsImage {
                    iai
                        .symbolRenderingMode(.hierarchical)
                }

                if showLabel! {
                    Text(text)
                }
                Spacer()
            }
            .padding(3)
        }
        .font(Theme.fontTitle)
    }
}
