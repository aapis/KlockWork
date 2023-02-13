//
//  FancyRandomColour.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyRandomJobColourPicker: View {
    public var job: Job
    @Binding public var colour: String
    
    @State private var colourChanged: Bool = false
    
    @EnvironmentObject public var updater: ViewUpdater
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 15)
                .background(Color.fromStored(job.colour!))
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
                colour = Color.fromStored(job.colour!).description
            })
            
            FancyButton(text: "Regenerate colour", action: regenerateColour, icon: "arrow.counterclockwise", showLabel: false)
                .padding(.leading)
        }.frame(height: 40)
    }
    
    private func regenerateColour() -> Void {
        let rndColour = Color.randomStorable()
        colour = Color.fromStored(rndColour).description
        job.colour = rndColour
        colourChanged = true
        
        PersistenceController.shared.save()
        updater.update()
    }
}
