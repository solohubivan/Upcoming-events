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
    
    var events: [EventModel] = []
    
    let eventStore = EKEventStore()

    func getEvents() -> [EventModel] {
        return events
    }
    
    func getEventsCount() -> Int {
        events.count
    }
    
    func fetchEvents(for timeInterval: Calendar.Component, completion: @escaping () -> Void) {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: timeInterval, value: 1, to: startDate)
            
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
    
    func fetchCustomEvents(for timeInterval: Calendar.Component, value: Int, completion: @escaping () -> Void) {
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
    
    func getCurrentPeriodLabel(for timeInterval: Calendar.Component) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
            
        let calendar = Calendar.current
        let today = Date()
        
        let endOfPeriod = calendar.date(byAdding: timeInterval, value: 1, to: today) ?? today
        
        let todayString = dateFormatter.string(from: today)
        let endOfPeriodString = dateFormatter.string(from: endOfPeriod)
        
        let year = calendar.component(.year, from: today)
        
        return "\(todayString) - \(endOfPeriodString), \(year)"
    }
    
    func getCustomPeriodLabel(for timeInterval: Calendar.Component, value: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
            
        let calendar = Calendar.current
        let today = Date()
        
        let endOfPeriod = calendar.date(byAdding: timeInterval, value: value, to: today) ?? today
        
        let todayString = dateFormatter.string(from: today)
        let endOfPeriodString = dateFormatter.string(from: endOfPeriod)
        
        let year = calendar.component(.year, from: today)
        
        return "\(todayString) - \(endOfPeriodString), \(year)"
    }
    
    func createClockTimeLabel(object: UISegmentedControl) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh : mm"
            
        let currentTime = formatter.string(from: Date())
            
        let hourFormatter = DateFormatter()
        hourFormatter.locale = Locale(identifier: "en_US_POSIX")
        hourFormatter.dateFormat = "a"
        let amPmString = hourFormatter.string(from: Date())

        let timeMode: TimeMode = amPmString == "AM" ? .am : .pm
        switch timeMode {
        case .am:
            object.selectedSegmentIndex = 0
        case .pm:
            object.selectedSegmentIndex = 1
        }
        
        return currentTime
    }
    
    func getCurrentMonthLabel() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let currentMonth = formatter.string(from: Date())
        return currentMonth
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
}
