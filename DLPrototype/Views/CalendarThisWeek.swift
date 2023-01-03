//
//  CalendarThisWeek.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2022-03-25.
//  Copyright © 2022 YegCollective. All rights reserved.
//

import SwiftUI

struct DayViewData: Identifiable, Hashable {
    public var id = UUID()
    public var dayOfWeek: String
    public var month: String
    public var day: String
    public var isWeekend: Bool = false
    public var isToday: Bool = false
    public var tableData: [String]
    public var numRecords: Int
}

struct CalendarThisWeek: View {
//    public var data: String = ""
    
    @ObservedObject public var records: Records
    
    @State private var thisWeek: [DayViewData] = []
    
//    private let model: Records
    
    var body: some View {
        HStack {
            ForEach(thisWeek.reversed(), id: \.self) { data in
                DayView(data: data)
//                DayView()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 110, maxHeight: 150)
            .onAppear(perform: afterAppear)
    }
    
    private func afterAppear() -> Void {
        generateDateList()
    }
    
    /// TODO: this method sucks, refactor and remove all the lets
    private func getRelativeDate(_ relativeDate: Int) -> DayViewData {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        
        let calendar = Calendar.current
        
        let midnight = calendar.startOfDay(for: Date())
        let requestedDate = calendar.date(byAdding: .day, value: relativeDate, to: midnight)!
        let formatted = formatter.string(from: requestedDate)
        
        let todayFormatter = DateFormatter()
        todayFormatter.dateFormat = "YYYY-MM-dd"
        let currentDate = todayFormatter.string(from: Date())
        
        let isToday = formatted.starts(with: currentDate)
        
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEEE"
        
        let dayOfWeek = dayOfWeekFormatter.string(from: requestedDate)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let rows = records.rowsStartsWith(term: formatted)
        
        let viewData = DayViewData(
            dayOfWeek: dayOfWeek,
            month: monthFormatter.string(from: requestedDate),
            day: dayFormatter.string(from: requestedDate),
            isWeekend: dayOfWeek.contains("Saturday") || dayOfWeek.contains("Sunday"),
            isToday: isToday,
            tableData: rows,
            numRecords: rows.count
        )
        
        return viewData
    }
    
    private func generateDateList() -> Void {
        for i in 0...6 {
            thisWeek.append(getRelativeDate(i * -1))
        }
    }
}

struct DayView: View {
    public var data: DayViewData
    
    var body: some View {
        ZStack {
            // frame background colours
            // .secondary for weekends
            // .red for today
            // .orange for all other days
            (data.isToday ? Color.red : (data.isWeekend ? Color.secondary : Color.orange))
                .edgesIgnoringSafeArea(.horizontal)
            
            VStack {
                HStack(alignment: .center) {
                    Text(data.dayOfWeek)
                        .fontWeight(.semibold)
                        .padding(.leading)
                    Spacer()
                    
                    Badge(count: data.numRecords)
                }
                
                Divider()
                
                Button(action: selectDay, label: {
                    Image(systemName: "arrow.down.app.fill")
                })
                    .padding(15)
                    .font(.largeTitle)
                    .background(Color.black.opacity(0.2))
                    .clipShape(Circle())
                    .buttonStyle(.borderless)
                    .help("Copy \(data.numRecords) rows")
                
                Divider()
                
                Text(data.month + " " + data.day)
                    .font(.subheadline)
                    .fontWeight(.light)
            }
        }
    }
    
    private func selectDay() -> Void {
        let pasteBoard = NSPasteboard.general
        
        pasteBoard.clearContents()
        pasteBoard.setString(data.tableData.joined(separator: "\n"), forType: .string)
    }
}

struct Badge: View {
    public var count: Int = 0
    
    var body: some View {
        VStack {
            ZStack {
                Color.black.opacity(0.1)
                    .clipShape(Capsule())
                    .help("\(count) records on this day")
                Text("\(count)")
                    .font(.body)
            }
                .frame(minWidth: 10, maxWidth: 30, minHeight: 10, maxHeight: 25)
                .padding(.trailing, 5)
        }
    }
}

struct CalendarThisWeek_Previews: PreviewProvider {
    static var previews: some View {
//        let data: String = "hi"
        
//        CalendarThisWeek(data: data)
        CalendarThisWeek(records: Records())
    }
}
