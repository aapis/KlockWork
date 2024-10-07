//
//  FancyColourPicker.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct FancyColourPicker: View {
    public let initialColourAsDouble: [Double]?
    public let initialColour: Color?
    public let onChange: ((Color) -> Void)
    public let showLabel: Bool
    @State private var asColour: Color
    @State private var asString: String = ""

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if showLabel {
                FancyLabel(text: "Colour")
                    .padding([.trailing], 10)
            }

            ColorPicker("", selection: $asColour)
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
            .border(Theme.base.opacity(0.3), width: 2)
            .frame(width: 200)

            Spacer()
        }
        .frame(height: 45)
        .onAppear(perform: {
            self.asString = self.asColour.description
        })
        .onChange(of: self.asColour) {
            self.colourChanged(self.asColour)
        }
    }
}

extension FancyColourPicker {
    init(initialColour: [Double], onChange: @escaping ((Color) -> Void), showLabel: Bool? = true) {
        self.initialColourAsDouble = initialColour
        self.initialColour = nil
        self.onChange = onChange

        if let shouldShowLabel = showLabel {
            self.showLabel = shouldShowLabel
        } else {
            self.showLabel = true
        }

        self.asColour = Color.fromStored(initialColour)
    }

    init(initialColour: Color, onChange: @escaping ((Color) -> Void), showLabel: Bool? = true) {
        self.initialColourAsDouble = nil
        self.initialColour = initialColour
        self.onChange = onChange

        if let shouldShowLabel = showLabel {
            self.showLabel = shouldShowLabel
        } else {
            self.showLabel = true
        }

        self.asColour = initialColour
    }

    private func colourChanged(_ newColour: Color) -> Void {
        self.asColour = newColour
        self.asString = self.asColour.description

        onChange(newColour)
    }
}
