//
//  FancyLoader.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-24.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct FancyLoader: View {
    public var message: String = "Loading..."

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            HStack {
                Spacer()
                ProgressView(message)
                Spacer()
            }
            .padding([.top, .bottom], 20)
            Spacer()
        }
    }
}
