//
//  FancyColourPicker.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct FancyColourPicker: View {
    public let initialColour: [Double]
    public let onChange: ((Color) -> Void)

    @State private var asColor: Color
    @State private var asString: String = ""

    var body: some View {
        HStack(spacing: 0) {
            FancyLabel(text: "Colour")
                .padding([.trailing], 10)

            ColorPicker("", selection: $asColor)
                .rotationEffect(.degrees(90))
                .frame(width: 20, height: 45)

            FancyTextField(
                placeholder: "Colour",
                lineLimit: 1,
                onSubmit: {},
                disabled: true,
                bgColour: Color.clear,
                text: $asString
            )
            .border(Color.black.opacity(0.1), width: 2)
            .frame(width: 200)

        }.frame(height: 40)
        .onAppear(perform: {
            asString = asColor.description
        })
        .onChange(of: asColor) { newColour in
            colourChanged(newColour)
        }
    }
}

extension FancyColourPicker {
    init(initialColour: [Double], onChange: @escaping ((Color) -> Void)) {
        self.initialColour = initialColour
        self.onChange = onChange
        asColor = Color.fromStored(initialColour)
    }

    private func colourChanged(_ newColour: Color) -> Void {
        asColor = newColour
        asString = asColor.description
        
        onChange(newColour)
    }
}
