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
    public let showLabel: Bool

    @State private var asColor: Color
    @State private var asString: String = ""

    var body: some View {
        HStack(spacing: 0) {
            if showLabel {
                FancyLabel(text: "Colour")
                    .padding([.trailing], 10)
            }

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

            Spacer()

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
    init(initialColour: [Double], onChange: @escaping ((Color) -> Void), showLabel: Bool? = true) {
        self.initialColour = initialColour
        self.onChange = onChange

        if let shouldShowLabel = showLabel {
            self.showLabel = shouldShowLabel
        } else {
            self.showLabel = true
        }

        asColor = Color.fromStored(initialColour)
    }

    private func colourChanged(_ newColour: Color) -> Void {
        asColor = newColour
        asString = asColor.description
        
        onChange(newColour)
    }
}
