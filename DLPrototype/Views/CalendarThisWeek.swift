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
}

struct CalendarThisWeek: View {
    public var data: String = ""
    
    @State private var thisWeek: [DayViewData] = []
    
    var body: some View {
        Divider()
        
        HStack {
            ForEach(thisWeek.reversed(), id: \.self) { data in
                DayView(viewData: data)
            }
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 100)
            .onAppear(perform: afterAppear)
        
        Divider()
    }
    
    private func afterAppear() -> Void {
        generateDateList()
    }
    
    private func getRelativeDate(_ relativeDate: Int) -> DayViewData {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        
        let calendar = Calendar.current
        
        let midnight = calendar.startOfDay(for: Date())
        let requestedDate = calendar.date(byAdding: .day, value: relativeDate, to: midnight)!
        let formatted = formatter.string(from: requestedDate)
        
        
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEEE"
        
        let dayOfWeek = dayOfWeekFormatter.string(from: requestedDate)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let month = monthFormatter.string(from: requestedDate)
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let day = dayFormatter.string(from: requestedDate)
        
        let isWeekend: Bool = dayOfWeek.contains("Saturday") || dayOfWeek.contains("Sunday")
        
        
        let dayData = DayViewData(dayOfWeek: dayOfWeek, month: month, day: day, isWeekend: isWeekend)
        
//        return formatted
        return dayData
    }
    
    private func generateDateList() -> Void {
        for i in -1...5 {
            thisWeek.append(getRelativeDate(i * -1))
        }
    }
}

struct DayView: View {
//    public var title: String = ""
//    public var data: String = ""
    public var viewData: DayViewData
    
//    @State private var isWeekend: Bool = true // TODO: FALSE by default!
    
    var body: some View {
        VStack {
            Text(viewData.dayOfWeek)
            Text(viewData.month)
            Text(viewData.day)
                .font(.largeTitle)
            
            ZStack {
                Rectangle()
                    .foregroundColor(viewData.isWeekend ? Color.secondary : Color.orange)
                
    //            Button(title, action: selectDay)
    //                .frame(minWidth: 0, maxWidth: .infinity)
    //                .padding()
    //                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 10, maxHeight: .infinity)
    //                .overlay(
    //                        RoundedRectangle(cornerRadius: 25)
    //                            .foregroundColor(Color.orange)
    //                        )
            }
//            .onAppear(perform: setIsWeekend)
        }
    }
    
//    private func setIsWeekend() -> Void {
//        if viewData.dayOfWeek.contains("Saturday") || viewData.dayOfWeek.contains("Sunday") {
//            isWeekend = true
//        }
//    }
    
    private func selectDay() -> Void {
//        print(data)
    }
}

struct CalendarThisWeek_Previews: PreviewProvider {
    static var previews: some View {
        let data: String = "hi"
//        let title: String = "title"
        
        CalendarThisWeek(data: data)
    }
}
