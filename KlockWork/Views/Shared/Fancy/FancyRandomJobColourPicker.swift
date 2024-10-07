//
//  FancyRandomColour.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct FancyRandomJobColourPicker: View {
    public var job: Job?
    @Binding public var colour: String
    public var onChange: (([Double]) -> Void)? = nil
    
    @State private var colourChanged: Bool = false
    @State private var newColour: [Double] = []
    
    @EnvironmentObject public var updater: ViewUpdater
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 15)
                .background(backgroundColour())
                .foregroundColor(.clear)
            
            FancyTextField(
                placeholder: "Colour",
                lineLimit: 1,
                onSubmit: {},
                disabled: true,
                bgColour: Color.clear,
                text: $colour
            )
            .border(Color.black.opacity(0.1), width: 2)
            .frame(width: 200)
            .onAppear(perform: {
                colour = backgroundColour().description
            })
            
            FancyButtonv2(text: "Regenerate colour", action: regenerateColour, icon: "arrow.counterclockwise", showLabel: false)
                .padding(.leading)
        }.frame(height: 40)
    }
    
    private func regenerateColour() -> Void {
        newColour = Color.randomStorable()
        colour = Color.fromStored(newColour).description
        colourChanged = true

        if onChange != nil {
            onChange!(newColour)
        }

        if job != nil {
            job!.colour = newColour
            PersistenceController.shared.save()
        }

        updater.update()
    }

    private func backgroundColour() -> Color {
        if job != nil {
            return Color.fromStored(job!.colour ?? Theme.rowColourAsDouble)
        }

        return Color.fromStored(newColour)
    }
}
