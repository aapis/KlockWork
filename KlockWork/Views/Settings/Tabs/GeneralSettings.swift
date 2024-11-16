//
//  GeneralSettingsView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import CoreSpotlight

struct GeneralSettings: View {
    @EnvironmentObject private var state: Navigation
    @AppStorage("tigerStriped") private var tigerStriped: Bool = false
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures: Bool = false
    @AppStorage("enableAutoCorrection") public var enableAutoCorrection: Bool = false
    @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5
    @AppStorage("general.syncColumns") public var syncColumns: Bool = false
    @AppStorage("general.defaultCompany") public var defaultCompany: Int = 0
    @AppStorage("general.showSessionInspector") public var showSessionInspector: Bool = false
    @AppStorage("general.spotlightIndex") public var spotlightIndex: Bool = false
    @AppStorage("general.columns") private var columns: Int = 3
    @AppStorage("general.shouldCheckLinkStatus") private var shouldCheckLinkStatus: Bool = false
    @AppStorage("general.appTintChoice") private var appTintChoice: Int = 0
    @AppStorage("general.usingBackgroundImage") private var usingBackgroundImage: Bool = false
    @AppStorage("general.wallpaperChoice") private var wallpaperChoice: Int = 0

    var body: some View {
        Form {
            Section("Visual appearance") {
                Toggle("Tiger stripe table rows", isOn: $tigerStriped)
                Toggle("Auto-correct text in text boxes", isOn: $enableAutoCorrection)
                Picker("App tint colour", selection: $appTintChoice) {
                    Text("Blue").tag(1)
                    Text("Purple").tag(2)
                    Text("Pink").tag(3)
                    Text("Red").tag(4)
                    Text("Orange").tag(5)
                    Text("Yellow").tag(6)
                    Text("Green").tag(7)
                    Text("Graphite").tag(8)
                }
                .onChange(of: self.appTintChoice) {
                    switch self.appTintChoice {
                    case 1: self.state.theme.tint = Color.blue
                    case 2: self.state.theme.tint = Color.purple
                    case 3: self.state.theme.tint = Color.pink
                    case 4: self.state.theme.tint = Color.red
                    case 5: self.state.theme.tint = Color.orange
                    case 7: self.state.theme.tint = Color.green
                    default:
                        self.state.theme.tint = Color.yellow
                    }
                }
                Toggle("Use background image", isOn: $usingBackgroundImage)
                if self.usingBackgroundImage {
                    Picker("Wallpaper", selection: $wallpaperChoice) {
                        Text("Choose...").tag(0)
                        Text("Square heaven").tag(1)
                        Text("Hotel rave").tag(2)
                        Text("Goldschlager").tag(3)
                    }
                    .onChange(of: self.wallpaperChoice) {
                        self.state.theme.wallpaperChoice = self.wallpaperChoice
                    }
                }
            }

            Group {
                Toggle("Enable experimental features (EXERCISE CAUTION)", isOn: $showExperimentalFeatures)

                if showExperimentalFeatures {
                    Toggle("Enable SessionInspector panel", isOn: $showSessionInspector)
                    Toggle("Spotlight (data is NOT shared with Apple)", isOn: $spotlightIndex)
                }
            }

            Group {
                Text("Export options")
                Toggle("Synchronize display and export columns", isOn: $syncColumns)
                    .help("Both table display and data exports will use the same columns set under 'Today > Display columns'")
            }

//          @TODO: uncomment when Spotlight search is fixed
//            Group {
//                Text("External services")
//                Toggle("Spotlight (data is NOT shared with Apple)", isOn: $spotlightIndex)
//            }

            Group {
                Picker("Number of columns to display", selection: $columns) {
                    Text("2").tag(2)
                    Text("3").tag(3)
                    Text("4").tag(4)
                    Text("5").tag(5)
                }
            }

            Toggle("Check if links are online", isOn: $shouldCheckLinkStatus)

            Group {
                Text("Defaults")
                CompanyPicker(onChange: self.companyPickerCallback, selected: defaultCompany)
                    .padding([.leading], 10)
            }
        }
        .padding(20)
        .onChange(of: self.spotlightIndex) {
            if self.spotlightIndex {
                self.index()
            } else {
                self.deindex()
            }
        }
    }
}

extension GeneralSettings {
    private func companyPickerCallback(_ cid: Int, _ sender: String?) -> Void {
        defaultCompany = cid
        let moc = PersistenceController.shared.container.viewContext

        let companies = CoreDataCompanies(moc: moc).active()
        for company in companies {
            company.isDefault = false
        }

        if let company = CoreDataCompanies(moc: moc).byPid(cid) {
            company.isDefault = true
        }
    }

    /// Perform Spotlight index
    /// - Returns: Void
    private func index() -> Void {
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

    private func deindex() {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: ["jobs"])
        print("[debug][Spotlight] Removed all data from Spotlight")
    }

    private func spotlightIndexer(error: (any Error)?) -> Void {
        if let error = error {
            print("[debug][Spotlight] ERROR: \(error)")
            print("[debug][Spotlight] Other")
        }
    }
}

struct GeneralSettingsPreview: PreviewProvider {
    static var previews: some View {
        GeneralSettings()
    }
}
