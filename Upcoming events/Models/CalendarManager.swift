//
//  CalendarManager.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 28.08.2024.
//

import Foundation
import EventKit
import UIKit

class CalendarManager {
    
    private var events: [EventModel] = []
    
    private let eventStore = EKEventStore()

    func getEvents() -> [EventModel] {
        return events
    }
    
    func fetchEvents(for timeInterval: Calendar.Component, value: Int, completion: @escaping () -> Void) {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: timeInterval, value: value, to: startDate)
            
        guard let endDate = endDate else { return }
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
                    
        events.removeAll()
                    
        for ekEvent in ekEvents {
            let event = EventModel(title: ekEvent.title ?? "No title", startDate: ekEvent.startDate, endDate: ekEvent.endDate)
            events.append(event)
        }
        completion()
    }
    
    func getCurrentPeriodLabel(for timeInterval: Calendar.Component, value: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
            
        let calendar = Calendar.current
        let today = Date()

        guard let endOfPeriod = calendar.date(byAdding: timeInterval, value: value, to: today) else { return "" }
            
        let todayString = dateFormatter.string(from: today)
        let endOfPeriodString = dateFormatter.string(from: endOfPeriod)
            
        let startYear = calendar.component(.year, from: today)
        let endYear = calendar.component(.year, from: endOfPeriod)
            
        if startYear == endYear {
            return "\(todayString) - \(endOfPeriodString), \(startYear)"
        } else {
            return "\(todayString), \(startYear) - \(endOfPeriodString), \(endYear)"
        }
    }
    
    func createClockTimeLabel(for date: Date, amPmSwitcher: UISegmentedControl) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh : mm"
        let timeString = formatter.string(from: date)
        let hourFormatter = DateFormatter()
        hourFormatter.locale = Locale(identifier: "en_US_POSIX")
        hourFormatter.dateFormat = "a"
        let amPmString = hourFormatter.string(from: date)

        let timeMode: TimeMode = amPmString == "AM" ? .am : .pm
        switch timeMode {
        case .am:
            amPmSwitcher.selectedSegmentIndex = 0
        case .pm:
            amPmSwitcher.selectedSegmentIndex = 1
        }
        
        return timeString
    }
    
    func getMonthDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    func getFullDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func formatTimeForLabel(_ interval: TimeInterval) -> String {
        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        switch (days, hours, minutes) {
        case (let d, _, _) where d > 0:
            return "\(d)d \(hours)h \(minutes)m"
        case (_, let h, _) where h > 0:
            return "\(h)h \(minutes)m"
        case (_, _, let m) where m > 0:
            return "\(m)m"
        default:
            return "less than a min"
        }
    }
    
    func filterEventsBySelectedTime(_ selectedTime: Date, forDate selectedDate: Date) -> [EventModel] {
        let calendar = Calendar.current
        let timeZone = TimeZone.current

        let selectedDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let selectedTimeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)

        var combinedComponents = DateComponents()
        combinedComponents.year = selectedDateComponents.year
        combinedComponents.month = selectedDateComponents.month
        combinedComponents.day = selectedDateComponents.day
        combinedComponents.hour = selectedTimeComponents.hour
        combinedComponents.minute = selectedTimeComponents.minute

        guard let combinedDateTime = calendar.date(from: combinedComponents) else { return [] }
        let localSelectedTime = combinedDateTime.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT(for: combinedDateTime)))

        let filteredEvents = events.filter { event in
            let localStartTime = event.startDate.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT(for: event.startDate)))
            let localEndTime = event.endDate.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT(for: event.endDate)))

            return localSelectedTime >= localStartTime && localSelectedTime <= localEndTime
        }
        return filteredEvents
    }
}
