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
    public var onChange: ((Any) -> Void)? = nil
    public var transparent: Bool? = false
    public var disabled: Bool? = false
    public var fgColour: Color? = Color.white
    public var bgColour: Color? = Theme.textBackground
    public var showLabel: Bool = false
    public var font: Font = Theme.fontTextField
    public var fieldStatus: Navigation.Forms.Field.FieldStatus = .standard

    @Binding public var text: String

    @AppStorage("enableAutoCorrection") public var enableAutoCorrection: Bool = false

    @EnvironmentObject private var nav: Navigation

    @FocusState public var hasFocus: Bool

    var body: some View {
        HStack(spacing: 5) {
            if showLabel {
                Text(placeholder)
                    .padding([.trailing], 10)
                    .font(font)
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
            .font(font)
            .textFieldStyle(.plain)
            .disableAutocorrection(!enableAutoCorrection)
            .padding()
            .onSubmit(onSubmit ?? {})
            .onChange(of: text) { newText in self.onChange != nil ? self.onChange!(newText) : nil }
            .background(fieldStatus == .standard ? (transparent! ? Color.clear : bgColour) : fieldStatus == .unsaved ? Color.yellow : Theme.cGreen) // sorry
            .frame(height: 45)
            .lineLimit(1)
            .disabled(disabled ?? false)
            .foregroundColor(disabled ?? false ? Color.gray : fieldStatus == .unsaved ? .black : fgColour)
            .textSelection(.enabled)
            .focused($hasFocus)
    }
    
    private var oneBigLine: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(font)
            .textFieldStyle(.plain)
            .disableAutocorrection(!enableAutoCorrection)
            .padding()
            .onSubmit(onSubmit ?? {})
            .onChange(of: text) { newText in self.onChange != nil ? self.onChange!(newText) : nil }
            .background(fieldStatus == .standard ? (transparent! ? Color.clear : bgColour) : fieldStatus == .unsaved ? Color.yellow : Theme.cGreen) // sorry
            .lineLimit(lineLimit...)
            .disabled(disabled ?? false)
            .foregroundColor(disabled ?? false ? Color.gray : fieldStatus == .unsaved ? .black : fgColour)
            .textSelection(.enabled)
            .focused($hasFocus)
    }
    
    private var multiLine: some View {
        TextEditor(text: $text)
            .font(Theme.fontSubTitle)
            .textFieldStyle(.plain)
            .disableAutocorrection(!enableAutoCorrection)
            .padding()
            .onSubmit(onSubmit ?? {})
            .onChange(of: text) { newText in self.onChange != nil ? self.onChange!(newText) : nil }
            .background(fieldStatus == .standard ? (transparent! ? Color.clear : bgColour) : fieldStatus == .unsaved ? Color.yellow : Theme.cGreen) // sorry{}
            .scrollContentBackground(.hidden)
            .lineLimit(lineLimit...)
            .disabled(disabled ?? false)
            .foregroundColor(disabled ?? false ? Color.gray : fieldStatus == .unsaved ? .black : fgColour)
            .textSelection(.enabled)
            .focused($hasFocus)
    }
}

extension FancyTextField {
    private func reset() -> Void {
        text = ""
    }
}
