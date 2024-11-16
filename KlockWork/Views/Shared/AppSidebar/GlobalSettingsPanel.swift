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
        .padding(.top, 1)
        .onAppear(perform: self.actionOnAppear)
    }

    // MARK: GlobalSettingsPanel.Pages
    internal struct Pages {
        // MARK: GlobalSettingsPanel.Pages.Themes
        internal struct Themes: View {
            @EnvironmentObject private var state: Navigation
            private var twoCol: [GridItem] { Array(repeating: .init(.flexible(minimum: 100)), count: 2) }
            private var wallpapers: [Wallpaper] {
                [
                    Wallpaper(asset: "", label: "None", choice: 0),
                    Wallpaper(asset: "wallpaper-01", label: "Square Heaven", choice: 1),
                    Wallpaper(asset: "wallpaper-02", label: "Hotel Rave", choice: 2),
                    Wallpaper(asset: "wallpaper-03", label: "Goldschläger", choice: 3),
                    Wallpaper(asset: "wallpaper-04", label: "Moon Landing", choice: 4)
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
                    AccentColour(colour: .gray, label: "Graphite"),
                ]
            }

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    self.SelectorWallpaper
                    self.SelectorAccentColour
                }
            }

            var SelectorWallpaper: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Wallpaper")
                        Spacer()
                    }
                    .padding(8)
                    ZStack(alignment: .bottom) {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: self.twoCol, alignment: .leading) {
                                ForEach(self.wallpapers) { wallpaper in wallpaper }
                            }
                        }
                        .padding(8)
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                            .blendMode(.softLight)
                            .frame(height: 30)
                    }
                    .frame(height: 140)
                }
                .background(Theme.textBackground)
            }

            var SelectorAccentColour: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Accent Colour")
                        Spacer()
                    }
                    .padding(8)

                    LazyVGrid(columns: self.twoCol, alignment: .leading) {
                        ForEach(self.colours) { colour in colour }
                    }
                    .padding(8)
                }
                .background(Theme.textBackground)
            }

            // MARK: GlobalSettingsPanel.Pages.Themes.Wallpaper
            internal struct Wallpaper: View, Identifiable {
                @EnvironmentObject private var state: Navigation
                @AppStorage("general.wallpaperChoice") private var wallpaperChoice: Int = 0
                @AppStorage("general.usingBackgroundImage") private var usingBackgroundImage: Bool = false
                var id: UUID = UUID()
                var asset: String
                var label: String
                var choice: Int = 0
                @State private var isHighlighted: Bool = false

                var body: some View {
                    Button {
                        self.state.theme.wallpaperChoice = self.choice
                        self.wallpaperChoice = self.choice
                        if self.choice == 0 {
                            self.usingBackgroundImage = false
                        } else {
                            self.usingBackgroundImage = true
                        }
                    } label: {
                        ZStack {
                            Image(self.asset)
                                .resizable()
                                .frame(height: 100)
                                .border(width: 8, edges: [.top, .bottom, .leading, .trailing], color: self.choice == self.wallpaperChoice ? self.state.theme.tint.opacity(1) : .white.opacity(0.5))
                            if self.isHighlighted {
                                Text(self.choice == self.wallpaperChoice ? "Current" : "Set \(self.label)")
                                    .padding(6)
                                    .background(Theme.base.opacity(0.7))
                                    .clipShape(.rect(cornerRadius: 5))
                            } else {
                                if self.choice == self.wallpaperChoice {
                                    Text(self.label)
                                        .padding(6)
                                        .background(Theme.base.opacity(0.7))
                                        .clipShape(.rect(cornerRadius: 5))
                                }
                            }
                        }
                        .useDefaultHover({ hover in self.isHighlighted = hover})
                    }
                    .clipShape(.rect(cornerRadius: 5))
                    .help(self.label)
                    .buttonStyle(.plain)
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

                var body: some View {
                    Button {
                        self.state.theme.tint = self.colour
                    } label: {
                        HStack {
                            Rectangle()
                                .fill(self.isHighlighted ? self.colour.opacity(1) : self.colour.opacity(0.8))
                                .frame(width: 40, height: 20)
                                .clipShape(.rect(cornerRadius: 5))
                            Text(self.label)
                                .foregroundStyle(self.colour == self.state.theme.tint ? self.state.theme.tint : .white)
                        }
//                        .border(width: 4, edges: [.top, .leading, .bottom, .trailing], color: self.colour == self.state.theme.tint ? self.state.theme.tint : .white)
                        .useDefaultHover({ hover in self.isHighlighted = hover})
                    }
                    .help(self.label)
                    .buttonStyle(.plain)
                }
            }
        }

        // MARK: GlobalSettingsPanel.Pages.General
        internal struct General: View {
            var body: some View {
                Text("General settings")
            }
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
                labelText: "Appearance",
                contents: AnyView(
                    GlobalSettingsPanel.Pages.Themes()
                )
            ),
            ToolbarButton(
                id: 1,
                helpText: "",
                icon: "xmark",
                labelText: "App settings",
                contents: AnyView(
                    GlobalSettingsPanel.Pages.General()
                )
            )
        ]
    }
}
