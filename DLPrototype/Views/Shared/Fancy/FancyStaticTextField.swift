//
//  FancyStaticTextField.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public struct FancyStaticTextField: View, Identifiable {
    public var id: UUID = UUID()

    public var placeholder: String
    public var lineLimit: Int
    public var onSubmit: (() -> Void)? = nil
    public var transparent: Bool? = false
    public var disabled: Bool? = false
    public var fgColour: Color? = Color.white
    public var bgColour: Color? = Theme.textBackground
    public var showLabel: Bool = false
    public var text: String = ""

    @State public var internalText: String = ""
    @State public var copied: Bool = false
    @State public var backgroundColour: Color = Theme.textBackground

    @AppStorage("enableAutoCorrection") public var enableAutoCorrection: Bool = false
    @AppStorage("today.maxCharsPerGroup") public var maxCharsPerGroup: Int = 0

    public var body: some View {
        HStack(alignment: .top, spacing: 1) {
            if showLabel {
                Text(placeholder)
                    .font(Theme.font)
                    .frame(width: 100)
            }

            if lineLimit == 1 {
                oneLine
            } else if lineLimit < 9 {
                oneBigLine
            } else {
                multiLine
            }

            actions
        }
        .background(backgroundColour)
        .onAppear(perform: {
            internalText = text

            backgroundColour = setBackground()
        })
        .onChange(of: copied) { colour in
            backgroundColour = setBackground()
        }
        .onHover { inside in
            if inside {
                if copied {
                    backgroundColour = Color.green.opacity(0.3)
                } else {
                    backgroundColour = Color.white.opacity(0.01)
                }

                if internalText.count > maxCharsPerGroup {
                    backgroundColour = Color.yellow.opacity(0.3)
                } else {
                    backgroundColour = Color.white.opacity(0.01)
                }
            } else {
                backgroundColour = setBackground()
            }
        }
    }

    private var actions: some View {
        VStack(alignment: .leading) {
            if copied {
                Button(action: copy) {
                    Image(systemName: "doc.on.clipboard")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.accentColor)
                }
                .buttonStyle(.plain)
                .help("Copied group to clipboard!")
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            } else {
                Button(action: copy) {
                    Image(systemName: "doc.on.clipboard")
                }
                .buttonStyle(.plain)
                .help("Copy this group")
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }

            Spacer()

            if internalText.count > maxCharsPerGroup {
                Image(systemName: "exclamationmark.triangle.fill")
                    .help("Too many characters, prune or split into multiple time tracker entries")
                    .symbolRenderingMode(.multicolor)
                    .foregroundColor(Color.yellow)
                Spacer()
            }

            Image(systemName: "number")
                .help("\(internalText.count) characters")

        }
        .frame(width: 35)
        .padding([.top, .bottom])
    }

    private var oneLine: some View {
        TextField(placeholder, text: $internalText)
            .font(Theme.font)
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
        TextField(placeholder, text: $internalText, axis: .vertical)
            .font(Theme.font)
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
        TextEditor(text: $internalText)
            .font(Theme.font)
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
        internalText = ""
    }

    private func copy() -> Void {
        ClipboardHelper.copy(text)
        copied = true
    }

    private func setBackground() -> Color {
        if copied {
            return Theme.rowStatusGreen
        }

        if internalText.count > maxCharsPerGroup {
            return Theme.rowStatusYellow
        }

        return transparent! ? Color.clear : bgColour!
    }
}

//struct FancyStaticTextField_Previews: PreviewProvider {
//    static var previews: some View {
//        FancyStaticTextField()
//    }
//}
