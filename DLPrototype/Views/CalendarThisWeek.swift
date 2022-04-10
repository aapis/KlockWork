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
    public var tableData: String
}

struct CalendarThisWeek: View {
    public var data: String = ""
    
    @State private var thisWeek: [DayViewData] = []
    
    var body: some View {
        HStack {
            ForEach(thisWeek.reversed(), id: \.self) { data in
                DayView(data: data)
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
        
        let viewData = DayViewData(
            dayOfWeek: dayOfWeek,
            month: monthFormatter.string(from: requestedDate),
            day: dayFormatter.string(from: requestedDate),
            isWeekend: dayOfWeek.contains("Saturday") || dayOfWeek.contains("Sunday"),
            isToday: isToday,
            tableData: "hello"
        )
        
        return viewData
    }
    
    private func generateDateList() -> Void {
        for i in -1...5 {
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
                Text(data.dayOfWeek)
                    .fontWeight(.semibold)
                
                // TODO: badge UI not ready for primetime yet
//                Badge(count: 0)
                
                Divider()
                
                Button(action: selectDay, label: {
                    Image(systemName: "arrow.down.app.fill")
                })
                    .padding(15)
                    .font(.largeTitle)
                    .background(Color.black.opacity(0.2))
                    .clipShape(Circle())
                    .buttonStyle(.borderless)
                
                Divider()
                
                Text(data.month + " " + data.day)
                    .font(.subheadline)
                    .fontWeight(.light)
            }
            .frame(alignment: .topTrailing)
        }
    }
    
    private func selectDay() -> Void {
        let pasteBoard = NSPasteboard.general
        
        pasteBoard.clearContents()
        pasteBoard.setString(data.tableData, forType: .string)
    }
}

struct Badge: View {
    public var count: Int = 0
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color.black.opacity(0.1))
            Text("\(count)")
        }
    }
}

struct CalendarThisWeek_Previews: PreviewProvider {
    static var previews: some View {
        let data: String = "hi"
        
        CalendarThisWeek(data: data)
    }
}
