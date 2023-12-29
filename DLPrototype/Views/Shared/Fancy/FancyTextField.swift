//
//  FancyTextField.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyTextField: View {
    public var placeholder: String
    public var lineLimit: Int = 1
    public var onSubmit: (() -> Void)? = nil
    public var transparent: Bool? = false
    public var disabled: Bool? = false
    public var fgColour: Color? = Color.white
    public var bgColour: Color? = Theme.textBackground
    public var showLabel: Bool = false
    
    @Binding public var text: String
    
    @AppStorage("enableAutoCorrection") public var enableAutoCorrection: Bool = false
    
    var body: some View {
        HStack(spacing: 5) {
            if showLabel {
                Text(placeholder)
                    .padding([.trailing], 10)
                    .font(Theme.font)
                    .frame(width: 120, height: 45, alignment: .trailing)
                    .background(Theme.textLabelBackground)
            }
            
            if lineLimit == 1 {
                oneLine
            } else if lineLimit < 15 {
                oneBigLine
            } else {
                multiLine
            }
        }
    }
    
    private var oneLine: some View {
        TextField(placeholder, text: $text)
            .font(Theme.fontTextField)
            .textFieldStyle(.plain)
            .disableAutocorrection(enableAutoCorrection)
            .padding()
            .onSubmit(onSubmit ?? {})
            .background(transparent! ? Color.clear : bgColour)
            .frame(height: 45)
            .lineLimit(1)
            .disabled(disabled ?? false)
            .foregroundColor(disabled ?? false ? Color.gray : fgColour)
            .textSelection(.enabled)
    }
    
    private var oneBigLine: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(Theme.fontTextField)
            .textFieldStyle(.plain)
            .disableAutocorrection(enableAutoCorrection)
            .padding()
            .onSubmit(onSubmit ?? {})
            .background(transparent! ? Color.clear : bgColour)
            .lineLimit(lineLimit...)
            .disabled(disabled ?? false)
            .foregroundColor(disabled ?? false ? Color.gray : fgColour)
            .textSelection(.enabled)
    }
    
    private var multiLine: some View {
        TextEditor(text: $text)
            .font(Theme.fontTextField)
            .textFieldStyle(.plain)
            .disableAutocorrection(enableAutoCorrection)
            .padding()
            .onSubmit(onSubmit ?? {})
            .background(transparent! ? Theme.textBackground : bgColour)
            .scrollContentBackground(.hidden)
            .lineLimit(lineLimit...)
            .disabled(disabled ?? false)
            .foregroundColor(disabled ?? false ? Color.gray : fgColour)
            .textSelection(.enabled)
    }
    
    private func reset() -> Void {
        text = ""
    }
}

struct FancyTextFieldPreview: PreviewProvider {
    @State static private var text: String = "Test text"
    
    static var previews: some View {
        VStack {
            FancyTextField(placeholder: "Small one", lineLimit: 1, onSubmit: {}, text: $text)
            FancyTextField(placeholder: "Medium one", lineLimit: 9, onSubmit: {}, text: $text)
            FancyTextField(placeholder: "Big one", lineLimit: 100, onSubmit: {}, text: $text)
        }
    }
}
