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
    
    @Binding public var text: String
    
    @AppStorage("enableAutoCorrection") public var enableAutoCorrection: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            LogTable.toolbarColour
            
            TextField(placeholder, text: $text, axis: .vertical)
                .font(Font.system(size: 16, design: .default))
                .textFieldStyle(.plain)
                .lineLimit(lineLimit...)
                .disableAutocorrection(enableAutoCorrection)
                .padding()
                .onSubmit(onSubmit)
        }
        .frame(maxHeight: 150)
    }
    
    private func submitAction() {
        print("hi")
    }
}

struct LogTextFieldPreview: PreviewProvider {
    static var previews: some View {
        let pView = Add(category: Category(title: "Daily"), records: Records())
        LogTextField(placeholder: "Type and hit enter to save", lineLimit: 6, onSubmit: {}, text: pView.$text)
    }
}
