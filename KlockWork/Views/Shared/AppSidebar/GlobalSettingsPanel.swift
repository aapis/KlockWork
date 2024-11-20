//
//  GlobalSettingsPanel.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-11-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import CoreSpotlight

struct GlobalSettingsPanel: View {
    private var tabs: [ToolbarButton] = [
        ToolbarButton(
            id: 0,
            helpText: "",
            icon: "circle.grid.3x3",
            selectedIcon: "circle.grid.3x3.fill",
            labelText: "App settings",
            contents: AnyView(
                GlobalSettingsPanel.Pages.General()
            )
        ),
        ToolbarButton(
            id: 1,
            helpText: "",
            icon: "paintbrush",
            selectedIcon: "paintbrush.fill",
            labelText: "Appearance",
            contents: AnyView(
                GlobalSettingsPanel.Pages.Themes()
            )
        ),
        ToolbarButton(
            id: 3,
            helpText: "",
            icon: "tray",
            selectedIcon: "tray.fill",
            labelText: "Today",
            contents: AnyView(
                GlobalSettingsPanel.Pages.Today()
            )
        ),
        ToolbarButton(
            id: 4,
            helpText: "",
            icon: "house",
            selectedIcon: "house.fill",
            labelText: "Dashboard",
            contents: AnyView(
                GlobalSettingsPanel.Pages.Dashboard()
            )
        ),
        ToolbarButton(
            id: 5,
            helpText: "",
            icon: "bell",
            selectedIcon: "bell.fill",
            labelText: "Appearance",
            contents: AnyView(
                GlobalSettingsPanel.Pages.Notifications()
            )
        ),
        ToolbarButton(
            id: 6,
            helpText: "",
            icon: "accessibility",
            selectedIcon: "accessibility.fill",
            labelText: "Accessibility",
            contents: AnyView(
                GlobalSettingsPanel.Pages.Accessibility()
            )
        )
    ]

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
    }

    // MARK: GlobalSettingsPanel.Pages
    internal struct Pages {
        // MARK: GlobalSettingsPanel.Pages.Themes
        internal struct Themes: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("general.usingBackgroundImage") private var usingBackgroundImage: Bool = false
            @AppStorage("general.usingBackgroundColour") private var usingBackgroundColour: Bool = false
            @AppStorage("widget.navigator.altViewModeEnabled") private var altViewModeEnabled: Bool = true
            @AppStorage("general.columns") private var columns: Int = 3
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
                        self.ColumnCountSelector
                    }
                }
                .onAppear(perform: self.actionOnAppear)
            }

            var ColumnCountSelector: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Number of columns")
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Picker("", selection: $columns) {
                            Text("2").tag(2)
                            Text("3").tag(3)
                            Text("4").tag(4)
                            Text("5").tag(5)
                        }
                        .frame(width: 70)
                    }
                    .padding(8)
                }
                .background(Theme.textBackground)
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

        // MARK: GlobalSettingsPanel.Pages.Setting
        // @TODO: Move this somewhere else
        internal struct Setting: View, Identifiable {
            var id: UUID = UUID()
            var icon: String? = nil
            var label: String
            var helpText: String
            var isChild: Bool = false
            @Binding public var isOn: Bool
            @State private var isHighlighted: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        if let icon = self.icon {
                            Image(systemName: icon)
                        }
                        Button(self.label, action: {self.isOn.toggle()})
                            .buttonStyle(.plain)
                        Spacer()
                        Toggle("", isOn: self.$isOn)
                    }
                    .help(self.helpText)
                    .padding(8)
                    .padding(.leading, self.isChild ? 16 : 0)
                }
                .useDefaultHover({ hover in self.isHighlighted = hover })
            }
        }

        // MARK: GlobalSettingsPanel.Pages.SettingGroup
        // @TODO: Move this somewhere else
        internal struct SettingGroup: View {
            public var title: String
            public var settings: [Setting]
            public var isScrollable: Bool = true

            var body: some View {
                if self.isScrollable {
                    ScrollView(showsIndicators: false) {
                        self.Main
                    }
                } else {
                    self.Main
                }
            }

            var Main: some View {
                VStack(alignment: .leading, spacing: 0) {
                    UI.Sidebar.Title(text: self.title, transparent: true)

                    ForEach(self.settings, id: \.id) { view in view }
                }
            }
        }

        // MARK: GlobalSettingsPanel.Pages.General
        internal struct General: View {
            typealias CompanySelector = WidgetLibrary.UI.UnifiedSidebar.RowButton
            @EnvironmentObject private var state: Navigation
            @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures: Bool = false
            @AppStorage("general.theme.kioskMode") private var inKioskMode: Bool = false
            @AppStorage("general.showSessionInspector") public var showSessionInspector: Bool = false
            @AppStorage("general.spotlightIndex") public var spotlightIndex: Bool = false
            @AppStorage("general.shouldCheckLinkStatus") private var shouldCheckLinkStatus: Bool = false
            @State private var defaultCompany: Company? = nil
            // When true, CompanySelector icon is "+", otherwise not strictly necessary
            @State private var isCompanySelectorPresented: Bool = true
            @FetchRequest private var companies: FetchedResults<Company>

            init() {
                _companies = CoreDataCompanies.all()
            }

            var body: some View {
                VStack(spacing: 0) {
                    SettingGroup(
                        title: "General",
                        settings: [
                            Setting(
                                icon: "exclamationmark.triangle.fill",
                                label: "Experimental Features",
                                helpText: "Enable or disable specific experimental features. Subject to change without warning.",
                                isOn:
                                    self.$showExperimentalFeatures
                            ),
                            Setting(
                                icon: "exclamationmark.triangle.fill",
                                label: "Kiosk mode",
                                helpText: "Experimental feature: Kiosk mode",
                                isChild: true,
                                isOn: self.$inKioskMode
                            ),
                            Setting(
                                icon: "exclamationmark.triangle.fill",
                                label: "Enable SessionInspector",
                                helpText: "Experimental feature: Enable SessionInspector",
                                isChild: true,
                                isOn: self.$showSessionInspector
                            ),
                            Setting(
                                icon: "exclamationmark.triangle.fill",
                                label: "Index items in Spotlight",
                                helpText: "Experimental feature: Index items in Spotlight",
                                isChild: true,
                                isOn: self.$spotlightIndex
                            ),
                            Setting(
                                label: "Check if web links are online",
                                helpText: "Used to determine whether an HTTP request is made to determine a URL's HTTP status response code.",
                                isOn: self.$shouldCheckLinkStatus
                            )
                        ],
                        isScrollable: false
                    )
                    self.DefaultCompanySelector
                    Spacer()
                }
                .onAppear(perform: self.actionOnAppear)
            }

            var DefaultCompanySelector: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        if self.defaultCompany != nil {
                            Text("Default Company")
                            Spacer()
                            Button {
                                self.actionClearDefaultCompany()
                            } label: {
                                Image(systemName: "arrow.clockwise.square.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                            .help("Reset default Company")
                            .buttonStyle(.plain)
                            .useDefaultHover({_ in})
                        } else {
                            Text("Choose a default company")
                            Spacer()
                        }
                    }
                    .padding(8)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            if let company = self.defaultCompany {
                                CompanySelector(
                                    text: company.name ?? "_COMPANY_NAME",
                                    alive: company.alive,
                                    active: company.alive,
                                    callback: {
                                        self.actionClearDefaultCompany()
                                    },
                                    isPresented: self.$isCompanySelectorPresented
                                )
                                .frame(height: 40)
                                .useDefaultHover({_ in})
                                .background(company.backgroundColor)
                                .foregroundStyle(company.backgroundColor.isBright() ? Theme.base : .white)
                            } else {
                                ForEach(self.companies, id: \.objectID) { company in
                                    CompanySelector(
                                        text: company.name ?? "_COMPANY_NAME",
                                        alive: company.alive,
                                        active: false,
                                        callback: {
                                            self.actionSetDefaultCompany(company)
                                        },
                                        isPresented: self.$isCompanySelectorPresented
                                    )
                                    .useDefaultHover({_ in})
                                    .background(company.backgroundColor)
                                    .foregroundStyle(company.backgroundColor.isBright() ? Theme.base : .white)
                                }
                            }
                        }
                    }
                    .help("Tap to choose your default company, which is used as a fallback.")
                }
            }
        }

        // MARK: GlobalSettingsPanel.Pages.Today
        internal struct Today: View {
            @EnvironmentObject private var state: Navigation
            @AppStorage("today.numPastDates") public var numPastDates: Int = 20
            @AppStorage("today.viewMode") public var viewMode: Int = 0
            @AppStorage("today.numWeeks") public var numWeeks: Int = 2
            @AppStorage("today.recordGrouping") public var recordGrouping: Int = 0
            @AppStorage("today.calendar") public var calendar: Int = -1
            @AppStorage("today.calendar.hasAccess") public var hasAccess: Bool = false
            @AppStorage("today.startOfDay") public var startOfDay: Int = 9
            @AppStorage("today.endOfDay") public var endOfDay: Int = 18
            @AppStorage("today.showColumnIndex") public var showColumnIndex: Bool = true
            @AppStorage("today.showColumnTimestamp") public var showColumnTimestamp: Bool = true
            @AppStorage("today.showColumnExtendedTimestamp") public var showColumnExtendedTimestamp: Bool = true
            @AppStorage("today.showColumnJobId") public var showColumnJobId: Bool = true
            @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures: Bool = false
            @AppStorage("today.maxCharsPerGroup") public var maxCharsPerGroup: Int = 2000
            @AppStorage("today.colourizeExportableGroupedRecord") public var colourizeExportableGroupedRecord: Bool = false
            @StateObject private var eventModel: CoreDataCalendarEvent = CoreDataCalendarEvent(moc: PersistenceController.shared.container.viewContext)
            @State private var calendars: [CustomPickerItem] = []

            var body: some View {
                VStack(spacing: 0) {
                    SettingGroup(
                        title: "Today",
                        settings: [
                            Setting(
                                label: "Show index column",
                                helpText: "Show/hide index column",
                                isOn: self.$showColumnIndex
                            ),
                            Setting(
                                label: "Show timestamp column",
                                helpText: "Show/hide timestamp column",
                                isOn: self.$showColumnTimestamp
                            ),
                            Setting(
                                label: "Show extended timestamp column",
                                helpText: "Show/hide extended timestamp column",
                                isOn: self.$showColumnExtendedTimestamp
                            ),
                            Setting(
                                label: "Show job column",
                                helpText: "Show/hide Job column",
                                isOn: self.$showColumnJobId
                            ),
                            Setting(
                                label: "Colourize grouped data records",
                                helpText: "Colourize grouped data records",
                                isOn: self.$colourizeExportableGroupedRecord
                            )
                        ],
                        isScrollable: false
                    )
                    HStack {
                        Text("Maximum number of characters per group")
                        Spacer()
                        Picker("", selection: self.$maxCharsPerGroup) {
                            Text("100").tag(100)
                            Text("1000").tag(1000)
                            Text("2000").tag(2000)
                            Text("3000").tag(3000)
                            Text("4000").tag(4000)
                        }
                        .frame(width: 70)
                    }
                    .padding(8)
                    HStack {
                        Text("Default tab")
                        Spacer()
                        Picker("", selection: self.$recordGrouping) {
                            Text("Chronologic").tag(0)
                            Text("Grouped").tag(1)
                            Text("Summarized").tag(2)
                        }
                        .frame(width: 140)
                    }
                    .padding(8)
                    HStack {
                        Text("Default view mode")
                        Spacer()
                        Picker("", selection: self.$viewMode) {
                            Text("Full").tag(1)
                            Text("Plain").tag(2)
                        }
                        .frame(width: 70)
                    }
                    .padding(8)
                    HStack {
                        Text("Start of your work day")
                        Spacer()
                        Picker("", selection: self.$startOfDay) {
                            ForEach(0..<25) { start in
                                Text("\(start)").tag(start)
                            }
                        }
                        .frame(width: 70)
                    }
                    .padding(8)
                    HStack {
                        Text("End of your work day")
                        Spacer()
                        Picker("", selection: $endOfDay) {
                            ForEach(0..<25) { end in
                                Text("\(end)").tag(end)
                            }
                        }
                        .frame(width: 70)
                    }
                    .padding(8)
                    VStack(alignment: .trailing) {
                        HStack {
                            if self.hasAccess && self.calendars.count > 0 {
                                Text("Active calendar")
                                Spacer()
                                Picker("", selection: $calendar) {
                                    ForEach(self.calendars, id: \.self) { item in
                                        Text(item.title).tag(item.tag)
                                    }
                                }
                                .frame(width: 140)
                            } else {
                                Button("Request access to calendar") {
                                    if #available(macOS 14.0, *) {
                                        self.eventModel.requestFullAccessToEvents({(granted, error) in
                                            self.hasAccess = granted
                                            self.actionOnAppear()
                                        })
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(8)
                }
                .onAppear(perform: self.actionOnAppear)
            }
        }

        // MARK: GlobalSettingsPanel.Pages.Dashboard
        internal struct Dashboard: View {
            @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5
            @AppStorage("dashboard.maxDaysUpcomingWork") public var maxDaysUpcomingWork: Double = 5
            @AppStorage("dashboard.showWelcomeHeader") private var showWelcomeHeader: Bool = true
            @AppStorage("dashboard.showRecentSearchesAboveResults") private var showRecentSearchesAboveResults: Bool = true

            var body: some View {
                VStack(spacing: 0) {
                    SettingGroup(
                        title: "Dashboard",
                        settings: [
                            Setting(
                                label: "Show \"Welcome\" header",
                                helpText: "Show \"Welcome\" header",
                                isOn: self.$showWelcomeHeader
                            ),
                            Setting(
                                label: "Show recent/saved searches above (or below) results",
                                helpText: "Show recent/saved searches above (or below) results",
                                isOn: self.$showRecentSearchesAboveResults
                            ),
                        ],
                        isScrollable: false
                    )
                    HStack {
                        Text("Number of days to preview")
                        Spacer()
                        Picker("", selection: self.$maxDaysUpcomingWork) {
                            ForEach(1..<31) { tag in
                                Text(String(tag)).tag(Double(tag))
                            }
                        }
                        .frame(width: 70)
                    }
                    .padding(8)
                    HStack {
                        Text("How many years of records would you like to show?")
                        Spacer()
                        Picker("", selection: self.$maxYearsPastInHistory) {
                            ForEach(1..<16) { tag in
                                Text(String(tag)).tag(Double(tag))
                            }
                        }
                        .frame(width: 70)
                    }
                    .padding(8)
                }
            }
        }

        // MARK: GlobalSettingsPanel.Pages.Notifications
        internal struct Notifications: View {
            @AppStorage("notifications.interval") private var notificationInterval: Int = 0

            var body: some View {
                VStack(spacing: 0) {
                    SettingGroup(
                        title: "Notifications",
                        settings: [],
                        isScrollable: false
                    )
                    HStack {
                        Text("Notification intervals")
                        Spacer()
                        Picker("", selection: $notificationInterval) {
                            Text("1 hour prior").tag(1)
                            Text("1 hour & 15 minutes prior").tag(2)
                            Text("1 hour, 15 minutes, and 5 minutes prior").tag(3)
                            Text("15 minutes prior").tag(4)
                            Text("5 minutes prior").tag(5)
                            Text("15 minutes & 5 minutes prior").tag(6)
                        }
                        .frame(width: 140)
                    }
                    .padding(8)
                }
            }
        }

        // MARK: GlobalSettingsPanel.Pages.Accessibility
        internal struct Accessibility: View {
            @AppStorage("settings.accessibility.showTabTitles") private var showTabTitles: Bool = true
            @AppStorage("settings.accessibility.showUIHints") private var showUIHints: Bool = true
            @AppStorage("settings.accessibility.showSelectorLabels") private var showSelectorLabels: Bool = true

            var body: some View {
                SettingGroup(
                    title: "Accessibility",
                    settings: [
                        Setting(
                            label: "Show tab titles",
                            helpText: "Show tab titles",
                            isOn: self.$showTabTitles
                        ),
                        Setting(
                            label: "Show hints & tutorials",
                            helpText: "Show hints & tutorials",
                            isOn: self.$showUIHints
                        ),
                        Setting(
                            label: "Show labels on buttons & dropdown menus",
                            helpText: "Show labels on buttons & dropdown menus",
                            isOn: self.$showSelectorLabels
                        ),
                    ]
                )
            }
        }
    }
}

extension GlobalSettingsPanel.Pages.Today {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if #available(macOS 14.0, *) {
            self.eventModel.requestFullAccessToEvents({(granted, error) in
                if granted {
                    self.calendars = CoreDataCalendarEvent(moc: self.state.moc).getCalendarsForPicker()
                } else {
                    print("[error][calendar] No calendar access")
                    print("[error][calendar] \(error.debugDescription)")
                }
            })
        }
    }
}

extension GlobalSettingsPanel.Pages.General {
    /// Onload handler. Sets view state.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let query = self.companies.filter({$0.isDefault == true}).first {
            self.defaultCompany = query
        }
    }
    
    /// Fires when tapping the reset button associated with this list
    /// - Returns: Void
    private func actionClearDefaultCompany() -> Void {
        self.defaultCompany = nil

        for company in self.companies {
            company.isDefault = false
        }
        PersistenceController.shared.save()
    }
    
    /// Fires when you choose a company from the list
    /// - Parameter company: Company
    /// - Returns: Void
    private func actionSetDefaultCompany(_ company: Company) -> Void {
        company.isDefault = true
        self.defaultCompany = company
        PersistenceController.shared.save()
    }
    
    /// Start indexing items in Spotlight
    /// - Returns: Void
    private func actionStartSpotlightIndexing() -> Void {
        var searchableItems = [CSSearchableItem]()
        let moc = PersistenceController.shared.container.viewContext
        let data = CoreDataJob(moc: moc).all(fetchLimit: 20).filter({$0.title != nil && $0.id != nil})

        for job in data {
            let attributeSet = CSSearchableItemAttributeSet(contentType: .plainText)
            attributeSet.displayName = job.title ?? String(job.idInt)
            attributeSet.contentDescription = job.overview ?? ""
            attributeSet.title = attributeSet.displayName
            print("[debug][Spotlight] displayName=\(attributeSet.title!) id=\(job.id_int())")

            let searchableItem = CSSearchableItem(uniqueIdentifier: job.jid.string, domainIdentifier: "jobs", attributeSet: attributeSet)
            searchableItems.append(searchableItem)
        }

        // Submit for indexing
        let index = CSSearchableIndex(name: "jobs")
        index.beginBatch()
        index.indexSearchableItems(searchableItems) { error in
            if error != nil {
                print("[debug][Spotlight] Error: \(error?.localizedDescription ?? "Unable to determine error")")
            } else {
                print("[debug][Spotlight] Indexed \(searchableItems.count) items with Spotlight")
            }
        }
//        index.endBatch(withClientState: .)
    }
    
    /// Remove all items from Spotlight
    /// - Returns: Void
    private func actionDeIndexSpotlight() -> Void {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: ["jobs"])
        print("[debug][Spotlight] Removed all data from Spotlight")
    }
    
    /// Error handline. @TODO: do we need this? migrated as-is from GeneralSettings
    /// - Parameter error: Error
    /// - Returns: Void
    private func spotlightIndexer(error: (any Error)?) -> Void {
        if let error = error {
            print("[debug][Spotlight] ERROR: \(error)")
            print("[debug][Spotlight] Other")
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
