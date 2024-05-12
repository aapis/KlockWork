//
//  GeneralSettingsView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import CoreSpotlight

struct GeneralSettings: View {
    @AppStorage("tigerStriped") private var tigerStriped: Bool = false
    @AppStorage("showExperimentalFeatures") private var showExperimentalFeatures: Bool = false
    @AppStorage("enableAutoCorrection") public var enableAutoCorrection: Bool = false
    @AppStorage("dashboard.maxYearsPastInHistory") public var maxYearsPastInHistory: Int = 5
    @AppStorage("general.syncColumns") public var syncColumns: Bool = false
    @AppStorage("general.defaultCompany") public var defaultCompany: Int = 0
    @AppStorage("general.showSessionInspector") public var showSessionInspector: Bool = false
    @AppStorage("general.spotlightIndex") public var spotlightIndex: Bool = false

    var body: some View {
        Form {
            Group {
                Text("Visual appearance")
                Toggle("Tiger stripe table rows", isOn: $tigerStriped)
                Toggle("Auto-correct text in text boxes", isOn: $enableAutoCorrection)
            }

            Group {
                Toggle("Enable experimental features (EXERCISE CAUTION)", isOn: $showExperimentalFeatures)

                if showExperimentalFeatures {
                    Toggle("Enable SessionInspector panel", isOn: $showSessionInspector)
                }
            }

            Group {
                Text("Export options")
                Toggle("Synchronize display and export columns", isOn: $syncColumns)
                    .help("Both table display and data exports will use the same columns set under 'Today > Display columns'")
            }

            Group {
                Text("External services")
                Toggle("Spotlight (data is NOT shared with Apple)", isOn: $spotlightIndex)
            }

            Group {
                Text("Defaults")
                CompanyPicker(onChange: self.companyPickerCallback, selected: defaultCompany)
                    .padding([.leading], 10)
            }
        }
        .padding(20)
        .onChange(of: spotlightIndex) { shouldIndex in
            if shouldIndex {
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

        let companies = CoreDataCompanies(moc: moc).all()
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
        let appData = [102, 503, 653, 998, 124, 587, 776, 354, 449, 287]

        appData.forEach {
            let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
            attributeSet.displayName = $0.description

            let searchableItem = CSSearchableItem(uniqueIdentifier: nil, domainIdentifier: "dlprototype", attributeSet: attributeSet)
            searchableItems.append(searchableItem)
        }

        // Submit for indexing
        CSSearchableIndex.default().indexSearchableItems(searchableItems)
        print("[debug][Spotlight] Indexed data with Spotlight")
        print("[debug][Spotlight] items=\(searchableItems)")
    }

    private func deindex() {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: ["dlprototype"])
        print("[debug][Spotlight] Removed all data from Spotlight")
    }
}

struct GeneralSettingsPreview: PreviewProvider {
    static var previews: some View {
        GeneralSettings()
    }
}
