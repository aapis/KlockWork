//
//  FancyGenericToolbar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct ToolbarButton: Hashable, Equatable {
    static func == (lhs: ToolbarButton, rhs: ToolbarButton) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var id: Int
    public var helpText: String
    public var icon: AnyView?
    public var label: AnyView?
    public var labelText: String?
    public var contents: AnyView?
    
    init(id: Int, helpText: String, label: AnyView?, contents: AnyView?) {
        self.id = id
        self.helpText = helpText
        self.label = label
        self.contents = contents
    }

    init(id: Int, helpText: String, icon: String, labelText: String, contents: AnyView?) {
        self.id = id
        self.helpText = helpText
        self.icon = AnyView(Image(systemName: icon).symbolRenderingMode(.hierarchical))
        self.label = AnyView(
            HStack {
                self.icon
                Text(labelText)
            }
        )
        self.labelText = labelText
        self.contents = contents
    }

    init(id: Int, helpText: String, icon: Image, labelText: String, contents: AnyView?) {
        self.id = id
        self.helpText = helpText
        self.icon = AnyView(icon)
        self.label = AnyView(
            HStack {
                self.icon.symbolRenderingMode(.hierarchical)
                Text(labelText)
            }
        )
        self.labelText = labelText
        self.contents = contents
    }
}

enum ToolbarMode {
    case full, compact
}

struct FancyGenericToolbar: View {
    typealias UI = WidgetLibrary.UI
    @EnvironmentObject public var nav: Navigation
    public let id: UUID = UUID()
    public var buttons: [ToolbarButton]
    public var standalone: Bool = false
    public var location: WidgetLocation = .content
    public var mode: ToolbarMode = .full
    public var page: PageConfiguration.AppPage = .today
    @AppStorage("sidebar.selectedTab") private var selected: Int = 0
    @State private var selectedId: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            GridRow {
                Group {
                    ZStack(alignment: .bottom) {
                        (self.location == .content ? UI.ThemeGradient() : nil)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 1) {
                                ForEach(buttons, id: \ToolbarButton.id) { button in
                                    TabView(
                                        toolbarId: self.id,
                                        button: button,
                                        location: location,
                                        mode: mode,
                                        page: self.page
                                    )

                                    if buttons.count == 1 {
                                        Text(buttons.first!.helpText)
                                            .padding(.leading, 10)
                                            .opacity(0.6)
                                    }
                                }
                            }
                            .clipShape(.rect(topLeadingRadius: self.location == .content ? 5 : 0, topTrailingRadius: self.location == .content ? 5 : 0))
                        }
                    }
                }
            }
            .frame(height: self.location == .content ? 50 : 32)

            GridRow {
                Group {
                    ZStack(alignment: .leading) {
                        if !standalone {
                            Theme.toolbarColour
                        }

                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(buttons, id: \ToolbarButton.id) { button in
                                    if button.id == self.selectedId /*self.selectedTabId(button.id)*/ && button.contents != nil {
                                        button.contents
                                            .clipShape(.rect(bottomLeadingRadius: self.location == .content ? 5 : 0, bottomTrailingRadius: self.location == .content ? 5 : 0))
                                    }
                                }
                            }
                        }
                        .padding(standalone ? 0 : 20)
                    }
                }
            }
        }
        .onAppear(perform: self.actionOnAppear)
    }

    struct TabView: View {
        @EnvironmentObject public var nav: Navigation
        public var toolbarId: UUID
        public var button: ToolbarButton
        public var location: WidgetLocation
        @AppStorage("sidebar.selectedTab") private var selected: Int = 0
        public var mode: ToolbarMode
        public var page: PageConfiguration.AppPage

        @State private var highlighted: Bool = false
        
        var body: some View {
            if location == .sidebar {
                if mode == .compact {
                    ButtonView.frame(width: 40)
                } else {
                    ButtonView
                }
            } else {
                ButtonView
            }
        }

        var ButtonView: some View {
            Button(action: {setActive(button)}) {
                ZStack(alignment: mode == .compact ? .center : .leading) {
                    ZStack(alignment: .bottom) {
                        (
                            selected == button.id ?
                            (
                                location == .sidebar ? Theme.base.opacity(0.2) : self.page.primaryColour
                            )
                            :
                            (
                                highlighted ? Theme.tabColour.opacity(0.6) : Theme.tabColour
                            )
                        )
                    }

                    if selected != button.id && location == .content {
                        VStack {
                            Spacer()
                            UI.ThemeGradient()
                        }
                    }

                    if location == .sidebar {
                        if mode == .compact {
                            button.icon
                                .padding(0)
                                .foregroundStyle(self.selected == self.button.id ? self.nav.session.job?.backgroundColor ?? .white : .white.opacity(0.5))
                        } else {
                            button.label
                                .padding(0)
                                .foregroundStyle(self.selected == self.button.id ? .white : .white.opacity(0.5))
                        }
                    } else {
                        if mode == .compact {
                            HStack(alignment: .center, spacing: 8) {
                                button.icon
                                    .foregroundStyle(self.selected == self.button.id ? self.nav.session.job?.backgroundColor ?? .white : .white.opacity(0.5))
                                    .font(.title3)

                                if self.selected == self.button.id && self.button.labelText != nil {
                                    Text(self.button.labelText!)
                                        .foregroundStyle(self.selected == self.button.id ? .white : .white.opacity(0.5))
                                        .font(.headline)
                                }
                            }
                            .padding([.top, .bottom], 10)
                            .padding([.leading, .trailing])
                        } else {
                            button.label.padding(16)
                                .foregroundStyle(self.selected == self.button.id ? .white : .white.opacity(0.5))
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .help(button.helpText)
            .useDefaultHover({ hover in highlighted = hover})
        }
    }
}

extension FancyGenericToolbar {
    private func actionOnAppear() -> Void {
        var tabId = self.id.hashValue
        if tabId < 0 {
            tabId = tabId * -1
        }
        var pSel = self.selected
        if pSel < 0 {
            pSel = pSel * -1
        }
        print("DERPO appear.tabId=\(tabId) selected=\(self.selected)")
//        self.selectedId = tabId - self.selected
//        print("DERPO appear.tabId=\(self.selectedId)")
    }

    private func selectedTabId(_ id: Int) -> Int {
        var tabId = Int(self.id.integers.0)
        if tabId < 0 {
            tabId *= -1
        }

        print("DERPO get.tabId=\(tabId) get.button.id=\(id)")
        return Int(id - Int(self.id.integers.0))
    }
}

extension FancyGenericToolbar.TabView {
    private func setActive(_ button: ToolbarButton) -> Void {
        let tabId = Int(Int(self.toolbarId.integers.0) + button.id)
        print("DERPO set.tabId=\(tabId) set.button.id=\(button.id)")
        selected = tabId
        self.nav.setInspector()
    }
}

extension UUID {
    // UUID is 128-bit, we need two 64-bit values to represent it
    var integers: (Int64, Int64) {
        var a: UInt64 = 0
        a |= UInt64(self.uuid.0)
        a |= UInt64(self.uuid.1) << 8
        a |= UInt64(self.uuid.2) << (8 * 2)
        a |= UInt64(self.uuid.3) << (8 * 3)
        a |= UInt64(self.uuid.4) << (8 * 4)
        a |= UInt64(self.uuid.5) << (8 * 5)
        a |= UInt64(self.uuid.6) << (8 * 6)
        a |= UInt64(self.uuid.7) << (8 * 7)

        var b: UInt64 = 0
        b |= UInt64(self.uuid.8)
        b |= UInt64(self.uuid.9) << 8
        b |= UInt64(self.uuid.10) << (8 * 2)
        b |= UInt64(self.uuid.11) << (8 * 3)
        b |= UInt64(self.uuid.12) << (8 * 4)
        b |= UInt64(self.uuid.13) << (8 * 5)
        b |= UInt64(self.uuid.14) << (8 * 6)
        b |= UInt64(self.uuid.15) << (8 * 7)

        return (Int64(bitPattern: a), Int64(bitPattern: b))
    }

    static func from(integers: (Int64, Int64)) -> UUID {
        let a = UInt64(bitPattern: integers.0)
        let b = UInt64(bitPattern: integers.1)
        return UUID(uuid: (
            UInt8(a & 0xFF),
            UInt8((a >> 8) & 0xFF),
            UInt8((a >> (8 * 2)) & 0xFF),
            UInt8((a >> (8 * 3)) & 0xFF),
            UInt8((a >> (8 * 4)) & 0xFF),
            UInt8((a >> (8 * 5)) & 0xFF),
            UInt8((a >> (8 * 6)) & 0xFF),
            UInt8((a >> (8 * 7)) & 0xFF),
            UInt8(b & 0xFF),
            UInt8((b >> 8) & 0xFF),
            UInt8((b >> (8 * 2)) & 0xFF),
            UInt8((b >> (8 * 3)) & 0xFF),
            UInt8((b >> (8 * 4)) & 0xFF),
            UInt8((b >> (8 * 5)) & 0xFF),
            UInt8((b >> (8 * 6)) & 0xFF),
            UInt8((b >> (8 * 7)) & 0xFF)
        ))
    }

    var data: Data {
        var data = Data(count: 16)
        // uuid is a tuple type which doesn't have dynamic subscript access...
        data[0] = self.uuid.0
        data[1] = self.uuid.1
        data[2] = self.uuid.2
        data[3] = self.uuid.3
        data[4] = self.uuid.4
        data[5] = self.uuid.5
        data[6] = self.uuid.6
        data[7] = self.uuid.7
        data[8] = self.uuid.8
        data[9] = self.uuid.9
        data[10] = self.uuid.10
        data[11] = self.uuid.11
        data[12] = self.uuid.12
        data[13] = self.uuid.13
        data[14] = self.uuid.14
        data[15] = self.uuid.15
        return data
    }

    static func from(data: Data?) -> UUID? {
        guard data?.count == MemoryLayout<uuid_t>.size else {
            return nil
        }
        return data?.withUnsafeBytes{
            guard let baseAddress = $0.bindMemory(to: UInt8.self).baseAddress else {
                return nil
            }
            return NSUUID(uuidBytes: baseAddress) as UUID
        }
    }
}
