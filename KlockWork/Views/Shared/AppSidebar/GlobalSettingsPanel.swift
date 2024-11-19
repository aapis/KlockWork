//
//  GlobalSettingsPanel.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-11-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct GlobalSettingsPanel: View {
    @State private var tabs: [ToolbarButton] = []

    var body: some View {
        VStack(spacing: 0) {
            UI.Sidebar.Title(text: "Settings", transparent: true)
            FancyGenericToolbar(
                buttons: self.tabs,
                standalone: true,
                location: .sidebar,
                mode: .compact,
                page: .find,
                alwaysShowTab: true,
                scrollable: false
            )
            Spacer()
        }
        .onAppear(perform: self.actionOnAppear)
    }

    // MARK: GlobalSettingsPanel.Pages
    internal struct Pages {
        // MARK: GlobalSettingsPanel.Pages.Themes
        internal struct Themes: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("general.usingBackgroundImage") private var usingBackgroundImage: Bool = false
            @AppStorage("general.usingBackgroundColour") private var usingBackgroundColour: Bool = false
            @AppStorage("widget.navigator.altViewModeEnabled") private var altViewModeEnabled: Bool = true
            @State private var backgroundColour: Color = .yellow
            @State private var style: Style = .opaque
            private var twoCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 2) }
            private var wallpapers: [Wallpaper] {
                [
                    Wallpaper(asset: "", label: "None", choice: 0),
                    Wallpaper(asset: "", label: "Custom", choice: 1),
                    Wallpaper(asset: "wallpaper-01", label: "Square Heaven", choice: 2),
                    Wallpaper(asset: "wallpaper-02", label: "Hotel Rave", choice: 3),
                    Wallpaper(asset: "wallpaper-03", label: "Goldschläger", choice: 4),
                    Wallpaper(asset: "wallpaper-04", label: "Moon Landing", choice: 5)
                ]
            }
            private var colours: [AccentColour] {
                [
                    AccentColour(colour: .blue, label: "Blue"),
                    AccentColour(colour: .purple, label: "Purple"),
                    AccentColour(colour: .pink, label: "Pink"),
                    AccentColour(colour: .red, label: "Red"),
                    AccentColour(colour: .orange, label: "Orange"),
                    AccentColour(colour: .yellow, label: "Yellow"),
                    AccentColour(colour: .green, label: "Green"),
//                    AccentColour(colour: .clear, label: "Custom"), // @TODO: uncomment and fix colour picker
                ]
            }

            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        UI.Sidebar.Title(text: "Appearance", transparent: true)
                        self.StyleSelector
                        self.PrimaryColourSelector
                        self.SelectorWallpaper
                        self.SelectorAccentColour
                        self.ColourLevelSelector
                    }
                }
                .onAppear(perform: self.actionOnAppear)
            }

            var ColourLevelSelector: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Colour Mode")
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Text(self.altViewModeEnabled ? "Full" : "Reduced")
                            .foregroundStyle(.gray)
                    }
                    .padding(8)
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: self.twoCol, alignment: .leading) {
                            ColourLevelBlock(isFullColour: false, image: Image("theme-colourLevel-low"))
                            ColourLevelBlock(isFullColour: true, image: Image("theme-colourLevel-high"))
                        }
                    }
                    .padding(8)
                }
                .background(Theme.textBackground)
            }

            var StyleSelector: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Theme")
                        Spacer()
                        Text(self.state.theme.style.label)
                            .foregroundStyle(.gray)
                    }
                    .padding(8)
                    LazyVGrid(columns: self.twoCol, alignment: .leading) {
                        ForEach(Style.allCases.sorted(by: {$0.index < $1.index}), id: \.self) { style in
                            StyleBlock(style: style)
                        }
                    }
                    .padding(8)
                }
                .background(Theme.textBackground)
            }

            var PrimaryColourSelector: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button("Solid colour", action: { self.usingBackgroundColour.toggle() })
                            .buttonStyle(.plain)
                            .useDefaultHover({ _ in})
                        Spacer()
                        Toggle("", isOn: self.$usingBackgroundColour)
                            .onChange(of: self.usingBackgroundColour) {
                                if self.usingBackgroundColour {
                                    self.usingBackgroundImage = false
                                } else {
                                    if !self.usingBackgroundImage {
                                        self.state.theme.style = .classic
                                    }
                                }
                            }
                    }
                    .foregroundStyle(self.usingBackgroundColour ? .white : .gray)
                    .padding(8)
                    if self.usingBackgroundColour {
                        VStack {
                            ColorPicker("Choose", selection: self.$backgroundColour)
                                .onChange(of: self.backgroundColour) {
                                    UserDefaults.standard.set(self.backgroundColour.toStored(), forKey: "customBackgroundColour")
                                    self.state.theme.customBackgroundColour = self.backgroundColour
                                }
                        }
                        .padding(8)
                    }
                }
                .background(Theme.textBackground)
            }

            var SelectorWallpaper: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button("Wallpaper", action: { self.usingBackgroundImage.toggle() })
                            .buttonStyle(.plain)
                            .useDefaultHover({ _ in})
                        Spacer()
                        Text(self.wallpapers[self.state.theme.wallpaperChoice].label)
                            .foregroundStyle(.gray)
                        Toggle("", isOn: self.$usingBackgroundImage)
                            .onChange(of: self.usingBackgroundImage) {
                                if self.usingBackgroundImage {
                                    self.usingBackgroundColour = false
                                } else {
                                    if !self.usingBackgroundColour {
                                        self.state.theme.style = .classic
                                    }
                                }
                            }
                    }
                    .foregroundStyle(self.usingBackgroundImage ? .white : .gray)
                    .padding(8)
                    if self.usingBackgroundImage {
                        LazyVGrid(columns: self.twoCol, alignment: .leading) {
                            ForEach(self.wallpapers) { wallpaper in wallpaper }
                        }
                        .padding(8)
                    }
                }
                .background(Theme.textBackground)
            }

            var SelectorAccentColour: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Accent colour")
                        Spacer()
                        Text(self.state.theme.tint.description.capitalized)
                            .foregroundStyle(.gray)
                    }
                    .padding(8)

                    LazyVGrid(columns: self.twoCol, alignment: .leading) {
                        ForEach(self.colours) { colour in colour }
                    }
                    .padding(8)
                }
                .background(Theme.textBackground)
            }

            // MARK: GlobalSettingsPanel.Pages.Themes.ColourLevelBlock
            internal struct ColourLevelBlock: View, Identifiable {
                @EnvironmentObject private var state: Navigation
                @AppStorage("widget.navigator.altViewModeEnabled") private var altViewModeEnabled: Bool = true
                var id: UUID = UUID()
                var isFullColour: Bool = false
                var image: Image
                @State private var isHighlighted: Bool = false

                var body: some View {
                    Button {
                        self.altViewModeEnabled = self.isFullColour
                    } label: {
                        ZStack {
                            image
                                .resizable()
                                .opacity(self.isHighlighted || self.altViewModeEnabled == self.isFullColour ? 1 : 0.5)
                                .border(width: 4, edges: [.top, .bottom, .leading, .trailing], color: self.isFullColour == self.altViewModeEnabled ? self.state.theme.tint.opacity(1) : .white.opacity(0.5))
                        }
                    }
                    .clipShape(.rect(cornerRadius: 5))
                    .help(self.isFullColour ? "Full colour" : "Reduced colour")
                    .buttonStyle(.plain)
                    .useDefaultHover({ hover in self.isHighlighted = hover })
                }
            }

            // MARK: GlobalSettingsPanel.Pages.Themes.StyleBlock
            internal struct StyleBlock: View, Identifiable {
                @EnvironmentObject private var state: Navigation
                @AppStorage("general.usingBackgroundImage") private var usingBackgroundImage: Bool = false
                @AppStorage("general.usingBackgroundColour") private var usingBackgroundColour: Bool = false
                var id: UUID = UUID()
                var style: Style
                @State private var isHighlighted: Bool = false

                var body: some View {
                    Button {
                        self.state.theme.style = self.style
                        UserDefaults.standard.set(self.style.index, forKey: "interfaceStyle")
                    } label: {
                        ZStack {
                            self.style.view
                                .opacity(self.isHighlighted || self.state.theme.style == self.style ? 1 : 0.5)
                                .border(width: 4, edges: [.top, .bottom, .leading, .trailing], color: self.state.theme.style == self.style ? self.state.theme.tint.opacity(1) : .white.opacity(0.5))
                            Text(self.style.label)
                                .padding(6)
                                .background(Theme.base.opacity(0.7))
                                .foregroundStyle(self.state.theme.style == self.style ? self.state.theme.tint : .white)
                                .clipShape(.rect(cornerRadius: 5))
                        }
                    }
                    .disabled([.opaque, .hybrid, .glass].contains(self.style) && (!self.usingBackgroundImage && !self.usingBackgroundColour))
                    .clipShape(.rect(cornerRadius: 5))
                    .help(style.label)
                    .buttonStyle(.plain)
                    .useDefaultHover({ hover in self.isHighlighted = hover })
                }
            }

            // MARK: GlobalSettingsPanel.Pages.Themes.Wallpaper
            internal struct Wallpaper: View, Identifiable {
                @EnvironmentObject private var state: Navigation
                @AppStorage("general.wallpaperChoice") private var wallpaperChoice: Int = 0
                @AppStorage("general.usingBackgroundImage") private var usingBackgroundImage: Bool = false
                @AppStorage("general.theme.isFilePickerPresented") private var isFilePickerPresented: Bool = false
                @AppStorage("general.theme.customBackground") private var customBackground: URL?
                var id: UUID = UUID()
                var asset: String
                var label: String
                var choice: Int = 0
                @State private var isHighlighted: Bool = false
                @State private var customImage: Image? = nil

                var body: some View {
                    Button {
                        self.state.theme.wallpaperChoice = self.choice
                        self.wallpaperChoice = self.choice
                        if self.choice == 0 {
                            self.usingBackgroundImage = false
                        } else if self.choice == 1 {
                            self.isFilePickerPresented = true
                        } else {
                            self.usingBackgroundImage = true
                        }
                    } label: {
                        ZStack {
                            if self.choice == 1, let image = self.customImage {
                                image
                                    .resizable()
                                    .frame(height: 100)
                                    .opacity(self.isHighlighted || self.choice == self.wallpaperChoice ? 1 : 0.5)
                                    .border(width: 4, edges: [.top, .bottom, .leading, .trailing], color: self.choice == self.wallpaperChoice ? self.state.theme.tint.opacity(1) : .white.opacity(0.5))

                            } else {
                                Image(self.asset)
                                    .resizable()
                                    .frame(height: 100)
                                    .opacity(self.isHighlighted || self.choice == self.wallpaperChoice ? 1 : 0.5)
                                    .border(width: 4, edges: [.top, .bottom, .leading, .trailing], color: self.choice == self.wallpaperChoice ? self.state.theme.tint.opacity(1) : .white.opacity(0.5))
                            }
                            Text(self.label)
                                .padding(6)
                                .background(Theme.base.opacity(0.7))
                                .foregroundStyle(self.choice == self.wallpaperChoice ? self.state.theme.tint : .white)
                                .clipShape(.rect(cornerRadius: 5))
                        }
                        .useDefaultHover({ hover in self.isHighlighted = hover})
                    }
                    .onAppear(perform: {
                        if let stored = self.state.theme.customWallpaperUrl {
                            if let imageData = try? Data(contentsOf: stored) {
                                if let image = NSImage(data: imageData) {
                                    self.customImage = Image(nsImage: image)
                                }
                            }
                        }
                    })
                    .clipShape(.rect(cornerRadius: 5))
                    .help(self.label)
                    .buttonStyle(.plain)
                    .fileImporter(isPresented: $isFilePickerPresented, allowedContentTypes: [.image]) { result in
                        switch result {
                        case .success(let url):
                            guard url.startAccessingSecurityScopedResource() else { return }
                            UserDefaults.standard.set(url, forKey: "customBackgroundUrl")
                            self.state.theme.customWallpaperUrl = url
                        case .failure(let error):
                            print("[error] TSP.Pages.Themes.Wallpaper Error selecting wallpaper: \(error)")
                        }
                    }

                }
            }

            // MARK: GlobalSettingsPanel.Pages.Themes.AccentColour
            internal struct AccentColour: View, Identifiable {
                @EnvironmentObject private var state: Navigation
                @AppStorage("general.appTintChoice") private var appTintChoice: Int = 0
                var id: UUID = UUID()
                var colour: Color
                var label: String
                @State private var isHighlighted: Bool = false
                @State private var customAccentColour: Color = .clear

                var body: some View {
                    Button {
                        self.state.theme.tint = self.colour
                    } label: {
                        HStack {
                            if self.label == "Custom" { // @TODO: don't use string comparison...
                                ColorPicker(self.label, selection: self.$customAccentColour)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                            } else {
                                Rectangle()
                                    .fill(self.isHighlighted ? self.colour.opacity(1) : self.colour.opacity(0.8))
                                    .frame(width: 40, height: 20)
                                    .clipShape(.rect(cornerRadius: 5))
                            }
                            Text(self.label)
                                .foregroundStyle(self.colour == self.state.theme.tint ? self.state.theme.tint : .white)
                        }
                        .useDefaultHover({ hover in self.isHighlighted = hover})
                    }
                    .help(self.label)
                    .buttonStyle(.plain)
                    .onAppear(perform: self.actionOnAppear)
                    .onChange(of: self.customAccentColour) {
                        if self.customAccentColour != self.state.theme.tint {
                            self.state.theme.tint = self.customAccentColour
                            UserDefaults.standard.set(self.customAccentColour.toStored(), forKey: "customAccentColour")
                        }
                    }
                }
            }

            // MARK: GlobalSettingsPanel.Pages.Themes.Style
            enum Style: CaseIterable {
                case classic, opaque, glass, hybrid

                var index: Int {
                    switch self {
                    case .classic: 0
                    case .opaque: 1
                    case .hybrid: 2
                    case .glass: 3
                    }
                }

                var view: some View {
                    switch self {
                    case .glass:
                        VStack(alignment: .center) {
                            Image("theme-style-glass")
                                .mask(
                                    Rectangle()
                                        .frame(width: 150, height: 100)
                                )
                            Text(self.label)
                        }
                        .frame(width: 150, height: 100)
                    case .hybrid:
                        VStack(alignment: .center) {
                            Image("theme-style-hybrid")
                                .mask(
                                    Rectangle()
                                        .frame(width: 150, height: 100)
                                )
                            Text(self.label)
                        }
                        .frame(width: 150, height: 100)
                    case .classic:
                        VStack(alignment: .center) {
                            Image("theme-style-classic")
                                .mask(
                                    Rectangle()
                                        .frame(width: 150, height: 100)
                                )
                            Text(self.label)
                        }
                        .frame(width: 150, height: 100)
                    default:
                        VStack(alignment: .center) {
                            Image("theme-style-opaque")
                                .mask(
                                    Rectangle()
                                        .frame(width: 150, height: 100)
                                )
                            Text(self.label)
                        }
                        .frame(width: 150, height: 100)
                    }
                }

                var label: String {
                    switch self {
                    case .glass: "Glass"
                    case .hybrid: "Hybrid"
                    case .classic: "Classic"
                    default: "Opaque"
                    }
                }
                
                /// Find case by index value
                /// - Parameter index: Int
                /// - Returns: Optional(self)
                static func byIndex(_ index: Int) -> Self? {
                    for w in Self.allCases {
                        if w.index == index {
                            return w
                        }
                    }

                    return nil
                }
            }
        }

        // MARK: GlobalSettingsPanel.Pages.General
        internal struct General: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures: Bool = false
            @AppStorage("general.theme.kioskMode") private var inKioskMode: Bool = false
//            private var twoCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 2) }

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    UI.Sidebar.Title(text: "General", transparent: true)
                    self.ExperimentalToggle
                    if self.showExperimentalFeatures {
                        self.KioskModeSelector
                    }
                }
            }

            var ExperimentalToggle: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Experimental Features")
                        Spacer()
                        Toggle("", isOn: self.$showExperimentalFeatures)
                    }
                    .help("Enable or disable specific experimental features. Subject to change without warning.")
                    .padding(8)
                }
                .background(Theme.textBackground)
            }

            var KioskModeSelector: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Kiosk Mode")
                        Spacer()
                        Toggle("", isOn: self.$inKioskMode)
                    }
                    .help("Experimental feature: Kiosk mode")
                    .padding(8)
                }
                .background(Theme.textBackground)
            }
        }
    }
}

extension GlobalSettingsPanel.Pages.Themes.AccentColour {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.customAccentColour = self.state.theme.tint
    }
}

extension GlobalSettingsPanel.Pages.Themes {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let colour = self.state.theme.customBackgroundColour {
            self.backgroundColour = colour
        }
    }
}

extension GlobalSettingsPanel {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.tabs = [
            ToolbarButton(
                id: 0,
                helpText: "",
                icon: "paintbrush",
                selectedIcon: "paintbrush.fill",
                labelText: "Appearance",
                contents: AnyView(
                    GlobalSettingsPanel.Pages.Themes()
                )
            ),
            ToolbarButton(
                id: 1,
                helpText: "",
                icon: "circle.grid.3x3",
                selectedIcon: "circle.grid.3x3.fill",
                labelText: "App settings",
                contents: AnyView(
                    GlobalSettingsPanel.Pages.General()
                )
            )
        ]
    }
}
