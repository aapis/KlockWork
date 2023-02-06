//
//  RecordResult.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct RecordResult: View {
    public var bucket: FetchedResults<LogRecord>
    @Binding public var text: String
    @Binding public var isLoading: Bool
    
    public let maxPerPage: Int = 100
    
    @State private var page: Int = 0
    @State private var numPages: Int = 1
    @State private var showChildren: Bool = false
    @State private var minimizeIcon: String = "arrowtriangle.down"
    
    var body: some View {
        GridRow {
            ZStack(alignment: .leading) {
                Theme.subHeaderColour
                
                HStack {
                    Text("\(bucket.count) Records")
                        
                    Spacer()
                    FancyButton(text: "Open", action: minimize, icon: minimizeIcon, transparent: true, showLabel: false)
                }
                .padding([.leading, .trailing], 10)
            }
        }
        .frame(height: 40)
        .onAppear(perform: setNumPages)
        .onChange(of: text) { _ in
            isLoading = true
            showChildren = false
            numPages = 1
            
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                if bucket.count > 0 {
                    isLoading = false
                    showChildren = true
                    setNumPages()
                } else {
                    minimize()
                }
            }
        }
        
        if bucket.count > 0 && showChildren {
            GridRow {
                ZStack {
                    Theme.rowColour
                    
                    ScrollView {
                        ForEach(0..<maxPerPage) { i in
                            let offset = (page > 0 ? maxPerPage * page : 0)
                            let item = bucket[i]
                            let entry = Entry(
                                timestamp: DateHelper.longDate(item.timestamp!),
                                job: item.job!,
                                message: item.message!
                            )
                            
                            LogRow(
                                entry: entry,
                                index: bucket.firstIndex(of: item),
                                colour: Color.clear,
                                selectedJob: $text
                            )
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
        } else {
            if isLoading {
                loading
            }
            
            Divider()
                .foregroundColor(Theme.darkBtnColour)
        }
        
        GridRow {
            ZStack(alignment: .leading) {
                Theme.subHeaderColour
                    
                if bucket.count > 0 && numPages > 1 {
                    HStack(spacing: 1) {
                        ForEach(0..<numPages) { i in
                            FancyButton(text: String(i + 1), action: {}, transparent: true, showIcon: false)
                                .background(Theme.darkBtnColour)
                        }
                    }
                    .padding([.leading, .trailing], 10)
                }
            }
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    var loading: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                ProgressView("Searching...")
                Spacer()
            }
            .padding([.top, .bottom], 20)
        }
    }
    
    private func minimize() -> Void {
        withAnimation(.easeInOut) {
            showChildren.toggle()
        }
        
        if showChildren {
            minimizeIcon = "arrowtriangle.down"
        } else {
            minimizeIcon = "arrowtriangle.up"
        }
    }
    
    private func setNumPages() -> Void {
        numPages = bucket.count/maxPerPage
        print("NPAGES: rr \(numPages)")
    }
}
