//
//  LogTextField.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct LogTextField: View {
    public var placeholder: String
    public var lineLimit: Int
    public var onSubmit: () -> Void
    public var transparent: Bool? = false
    
    @Binding public var text: String
    
    @AppStorage("enableAutoCorrection") public var enableAutoCorrection: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            if lineLimit == 1 {
                oneLine
            } else if lineLimit < 9 {
                oneBigLine
            } else {
                multiLine
            }
        }
    }
    
    private var oneLine: some View {
        TextField(placeholder, text: $text)
            .font(Theme.font)
            .textFieldStyle(.plain)
            .disableAutocorrection(enableAutoCorrection)
            .padding()
            .onSubmit(onSubmit)
            .background(transparent! ? Color.clear : Theme.toolbarColour)
            .frame(height: 45)
            .lineLimit(1)
    }
    
    private var oneBigLine: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(Theme.font)
            .textFieldStyle(.plain)
            .disableAutocorrection(enableAutoCorrection)
            .padding()
            .onSubmit(onSubmit)
            .background(transparent! ? Color.clear : Theme.toolbarColour)
            .lineLimit(lineLimit...)
    }
    
    private var multiLine: some View {
        TextEditor(text: $text)
            .font(Theme.font)
            .textFieldStyle(.plain)
            .disableAutocorrection(enableAutoCorrection)
                    .padding()
            .onSubmit(onSubmit)
            .background(transparent! ? Color.black.opacity(0.1) : Theme.toolbarColour)
            .scrollContentBackground(.hidden)
            .lineLimit(lineLimit...)
    }
}

struct LogTextFieldPreview: PreviewProvider {
    static var previews: some View {
        let pView = Today()
        
        VStack {
            LogTextField(placeholder: "Small one", lineLimit: 1, onSubmit: {}, text: pView.$text)
            LogTextField(placeholder: "Medium one", lineLimit: 9, onSubmit: {}, text: pView.$text)
            LogTextField(placeholder: "Big one", lineLimit: 100, onSubmit: {}, text: pView.$text)
        }
    }
}
