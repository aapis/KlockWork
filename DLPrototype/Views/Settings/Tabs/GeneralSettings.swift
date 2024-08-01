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
    @AppStorage("general.experimental.cli") private var cliMode: Bool = false
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
                    Toggle("Spotlight (data is NOT shared with Apple)", isOn: $spotlightIndex)
                    Toggle("Enable CLI mode", isOn: $cliMode)
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
                print("[debug][Spotlight] Error: \(error?.localizedDescription)")
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
        print("[debug][Spotlight] ERROR: \(error)")
        print("[debug][Spotlight] Other")
    }
}

struct GeneralSettingsPreview: PreviewProvider {
    static var previews: some View {
        GeneralSettings()
    }
}
