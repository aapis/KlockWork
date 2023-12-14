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
    public let onChange: (([Double]) -> Void)

    @State private var asColor: Color
    @State private var asString: String = ""

    var body: some View {
        HStack(spacing: 0) {
            FancyLabel(text: "Colour")
                .padding([.trailing], 10)
            Rectangle()
                .frame(width: 20)
                .background(asColor)
                .foregroundColor(.clear)

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
            .onAppear(perform: {
                asString = asColor.description
            })

            FancyButtonv2(text: "Regenerate colour", action: regenerateColour, icon: "arrow.counterclockwise", showLabel: false)
                .padding(.leading, 5)
        }.frame(height: 40)
    }
}

extension FancyColourPicker {
    init(initialColour: [Double], onChange: @escaping (([Double]) -> Void)) {
        self.initialColour = initialColour
        self.onChange = onChange
        asColor = Color.fromStored(initialColour)
    }

    private func regenerateColour() -> Void {
        let rndColour = Color.randomStorable()
        asColor = Color.fromStored(rndColour)
        asString = asColor.description
        
        onChange(rndColour)
    }
}
