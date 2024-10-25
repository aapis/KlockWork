//
//  FancyTextField.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct FancyTextField: View {
    public var placeholder: String
    public var lineLimit: Int = 1
    public var onSubmit: (() -> Void)? = nil
    public var onChange: ((Any) -> Void)? = nil
    public var transparent: Bool = false
    public var disabled: Bool? = false
    public var fgColour: Color? = Color.white
    public var bgColour: Color? = Theme.textBackground
    public var showLabel: Bool = false
    public var font: Font = Theme.fontTextField
    public var fieldStatus: Navigation.Forms.Field.FieldStatus = .standard
    public var padding: Double = 16

    @Binding public var text: String

    @AppStorage("enableAutoCorrection") public var enableAutoCorrection: Bool = false

    @EnvironmentObject private var nav: Navigation

    @FocusState public var hasFocus: Bool

    var body: some View {
        HStack {
            if showLabel {
                FancyLabel(text: self.placeholder)
            }
            ZStack(alignment: .topLeading) {
                if !self.transparent {
                    LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                        .blendMode(.softLight)
                        .frame(height: self.lineLimit < 15 ? 40 : 80)
                        .opacity(0.2)
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
    }
    
    private var oneLine: some View {
        TextField(placeholder, text: $text)
            .font(font)
            .textFieldStyle(.plain)
            .disableAutocorrection(!enableAutoCorrection)
            .padding(padding)
            .onSubmit(onSubmit ?? {})
            .onChange(of: text) { self.onChange != nil ? self.onChange!(self.text) : nil }
            .background(fieldStatus == .standard ? (transparent ? Color.clear : bgColour) : fieldStatus == .unsaved ? Color.yellow : Theme.cGreen) // sorry
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
            .padding(padding)
            .onSubmit(onSubmit ?? {})
            .onChange(of: text) { self.onChange != nil ? self.onChange!(self.text) : nil }
            .background(fieldStatus == .standard ? (transparent ? Color.clear : bgColour) : fieldStatus == .unsaved ? Color.yellow : Theme.cGreen) // sorry
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
            .padding(padding)
            .onSubmit(onSubmit ?? {})
            .onChange(of: text) { self.onChange != nil ? self.onChange!(self.text) : nil }
            .background(fieldStatus == .standard ? (transparent ? Color.clear : bgColour) : fieldStatus == .unsaved ? Color.yellow : Theme.cGreen) // sorry
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
